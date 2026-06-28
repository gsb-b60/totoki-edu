import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';
import 'package:totoki_extract/features/ielts/models/article_fragment.dart';
import 'package:totoki_extract/features/ielts/parsers/article_parser.dart';
import 'package:totoki_extract/features/ielts/parsers/answer_parser.dart';
import 'package:totoki_extract/features/ielts/parsers/question_normalizer.dart';
import 'package:totoki_extract/features/ielts/parsers/question_parser.dart';

class ReadingNoti extends ChangeNotifier {
  String title = "";
  String articleText = "";
  List<ArticleFragment> articleFragments = [];
  List<ParagraphGroup> questions = [];
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic> _dictionary = {};
  int _seriesId = 0;
  int _testId = 0;
  int _part = 0;
  int _questionGroup = 0;

  bool get hasError => errorMessage != null;

  String? lookupWord(String word) {
    final entry = _dictionary[word.toLowerCase()];
    return entry?["quick_def"] as String?;
  }

  String _buildErrorContext() {
    return "series: $_seriesId | test: $_testId | part: $_part | questionGroup: $_questionGroup";
  }

  Future<void> loadPassage({
    required int seriesId,
    required int testId,
    required int part,
    required int questionGroup,
  }) async {
    _seriesId = seriesId;
    _testId = testId;
    _part = part;
    _questionGroup = questionGroup;
    errorMessage = null;
    questions = [];
    articleFragments = [];
    articleText = "";
    title = "";
    isLoading = true;
    notifyListeners();

    final testPath = "assets/ielts/test/$seriesId-$testId-$part.json";
    final questionPath = "assets/ielts/question/$seriesId-$testId-$part.json";
    final answerPath = "assets/ielts/answer/$seriesId-$testId.json";
    final dictPath = "assets/ielts/jsondictionary.json";

    Map<String, dynamic>? questionData;

    try {
      final results = await Future.wait([
        rootBundle.loadString(testPath),
        rootBundle.loadString(questionPath),
        rootBundle.loadString(answerPath),
        rootBundle.loadString(dictPath),
      ]);

      _dictionary = jsonDecode(results[3]) as Map<String, dynamic>;
      final data = jsonDecode(results[0]) as Map<String, dynamic>;
      questionData = jsonDecode(results[1]) as Map<String, dynamic>;
      final answerData = jsonDecode(results[2]) as Map<String, dynamic>;

      if (data["test_text"] == null) {
        errorMessage = "[test file] Missing 'test_text' key\nFile: $testPath\n${_buildErrorContext()}";
        isLoading = false; notifyListeners(); return;
      }

      final article = ArticleParser.parse(data, seriesId);
      title = article.title;
      articleFragments = article.fragments;
      articleText = article.articleText;

      final answers = AnswerParser.parse(answerData["reading"] as List?);
      final qList = questionData["test_question"] as List? ?? [];

      if (qList.isEmpty) {
        errorMessage = "[question file] No 'test_question' array or it is empty\nFile: $questionPath\n${_buildErrorContext()}";
        isLoading = false; notifyListeners(); return;
      }

      if (questionGroup < 1 || questionGroup > qList.length) {
        errorMessage = "[question file] questionGroup $questionGroup out of range — valid range: 1..${qList.length}\nFile: $questionPath\n${_buildErrorContext()}";
        isLoading = false; notifyListeners(); return;
      }

      final normalized = QuestionNormalizer.normalizeGroup(
        qList[questionGroup - 1] as Map<String, dynamic>,
      );
      questions = QuestionParser.parse(
        qGroup: normalized,
        answerLookup: answers.optionLookup,
        textAnswerLookup: answers.textLookup,
        seriesId: seriesId,
      );

      isLoading = false;
      notifyListeners();
    } on FlutterError catch (e) {
      final msg = e.message;
      String source = "unknown";
      if (msg.contains(testPath)) source = "test";
      else if (msg.contains(questionPath)) source = "question";
      else if (msg.contains(answerPath)) source = "answer";
      else if (msg.contains(dictPath)) source = "dictionary";
      errorMessage = "[$source file] Failed to load asset\n"
          "File: $testPath\n"
          "Details: $msg\n"
          "${_buildErrorContext()}";
      isLoading = false;
      notifyListeners();
    } on FormatException catch (e) {
      final source = _identifySource(e.source ?? "", testPath, questionPath, answerPath, dictPath);
      errorMessage = "[$source file] Invalid JSON\n"
          "File: $source\n"
          "Error: ${e.message}\n"
          "Offset: ${e.offset}\n"
          "${_buildErrorContext()}";
      isLoading = false;
      notifyListeners();
    } on UnsupportedError catch (e) {
      final qIdx = questionGroup - 1;
      final rawList = questionData?["test_question"] as List? ?? [];
      final rawGroup = 0 <= qIdx && qIdx < rawList.length ? rawList[qIdx] : <String, dynamic>{};
      errorMessage = "[question file] Unknown question type\n"
          "Error: ${e.message}\n"
          "Raw JSON: ${const JsonEncoder.withIndent("  ").convert(rawGroup)}\n"
          "File: $questionPath\n"
          "${_buildErrorContext()}";
      isLoading = false;
      notifyListeners();
    } on TypeError catch (e) {
      final source = _identifySource(e.toString(), testPath, questionPath, answerPath, dictPath);
      errorMessage = "[$source file] Type mismatch — unexpected JSON shape\n"
          "File: $source\n"
          "Error: $e\n"
          "${_buildErrorContext()}\n"
          "Tip: Check if the question type is handled by the parser.";
      isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      final source = _identifySource(e.toString(), testPath, questionPath, answerPath, dictPath);
      errorMessage = "[$source file] Unexpected error\n"
          "File: $source\n"
          "Error: $e\n"
          "Stack:\n$stack\n"
          "${_buildErrorContext()}";
      isLoading = false;
      notifyListeners();
    }
  }

  String _identifySource(String msg, String t, String q, String a, String d) {
    if (msg.contains(t)) return t;
    if (msg.contains(q)) return q;
    if (msg.contains(a)) return a;
    if (msg.contains(d)) return d;
    return t;
  }
}
