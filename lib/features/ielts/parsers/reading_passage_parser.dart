import 'dart:convert';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;
import 'package:totoki_extract/features/ielts/models/reading_passage_result.dart';
import 'package:totoki_extract/features/ielts/parsers/answer_parser.dart';
import 'package:totoki_extract/features/ielts/parsers/article_parser.dart';
import 'package:totoki_extract/features/ielts/parsers/question_normalizer.dart';
import 'package:totoki_extract/features/ielts/parsers/question_parser.dart';

class ReadingPassageException implements Exception {
  final String message;
  const ReadingPassageException(this.message);
  @override
  String toString() => message;
}

class ReadingPassageParser {
  ReadingPassageParser._();

  static Future<ReadingPassageResult> parse({
    required int seriesId,
    required int testId,
    required int part,
    required int questionGroup,
  }) async {
    final testPath = 'assets/ielts/test/$seriesId-$testId-$part.json';
    final questionPath = 'assets/ielts/question/$seriesId-$testId-$part.json';
    final answerPath = 'assets/ielts/answer/$seriesId-$testId.json';
    final dictPath = 'assets/ielts/jsondictionary.json';

    Map<String, dynamic>? questionData;

    try {
      final results = await Future.wait([
        rootBundle.loadString(testPath),
        rootBundle.loadString(questionPath),
        rootBundle.loadString(answerPath),
        rootBundle.loadString(dictPath),
      ]);

      final dictionary = jsonDecode(results[3]) as Map<String, dynamic>;
      final data = jsonDecode(results[0]) as Map<String, dynamic>;
      questionData = jsonDecode(results[1]) as Map<String, dynamic>;
      final answerData = jsonDecode(results[2]) as Map<String, dynamic>;

      if (data['test_text'] == null) {
        throw ReadingPassageException(
          "[test file] Missing 'test_text' key\n"
          "File: $testPath\n"
          "series: $seriesId | test: $testId | part: $part | questionGroup: $questionGroup",
        );
      }

      final article = ArticleParser.parse(data, seriesId);

      final answers = AnswerParser.parse(answerData['reading'] as List?);
      final qList = questionData['test_question'] as List? ?? [];

      if (qList.isEmpty) {
        throw ReadingPassageException(
          "[question file] No 'test_question' array or it is empty\n"
          "File: $questionPath\n"
          "series: $seriesId | test: $testId | part: $part | questionGroup: $questionGroup",
        );
      }

      if (questionGroup < 1 || questionGroup > qList.length) {
        throw ReadingPassageException(
          "[question file] questionGroup $questionGroup out of range — valid range: 1..${qList.length}\n"
          "File: $questionPath\n"
          "series: $seriesId | test: $testId | part: $part | questionGroup: $questionGroup",
        );
      }

      final normalized = QuestionNormalizer.normalizeGroup(
        qList[questionGroup - 1] as Map<String, dynamic>,
      );
      final questions = QuestionParser.parse(
        qGroup: normalized,
        answerLookup: answers.optionLookup,
        textAnswerLookup: answers.textLookup,
        seriesId: seriesId,
      );

      return ReadingPassageResult(
        title: article.title,
        fragments: article.fragments,
        articleText: article.articleText,
        questions: questions,
        dictionary: dictionary,
      );
    } catch (e, stack) {
      if (e is FlutterError) {
        final msg = e.message;
        String source = 'unknown';
        if (msg.contains(testPath)) {
          source = 'test';
        } else if (msg.contains(questionPath)) {
          source = 'question';
        } else if (msg.contains(answerPath)) {
          source = 'answer';
        } else if (msg.contains(dictPath)) {
          source = 'dictionary';
        }
        throw ReadingPassageException(
          '[$source file] Failed to load asset\n'
          "File: $testPath\n"
          'Details: $msg\n'
          "series: $seriesId | test: $testId | part: $part | questionGroup: $questionGroup",
        );
      }
      if (e is FormatException) {
        final source = _identifySource(e.source ?? '', testPath, questionPath, answerPath, dictPath);
        throw ReadingPassageException(
          '[$source file] Invalid JSON\n'
          "File: $source\n"
          'Error: ${e.message}\n'
          'Offset: ${e.offset}\n'
          "series: $seriesId | test: $testId | part: $part | questionGroup: $questionGroup",
        );
      }
      if (e is UnsupportedError) {
        final qIdx = questionGroup - 1;
        final rawList = questionData?['test_question'] as List? ?? [];
        final rawGroup = 0 <= qIdx && qIdx < rawList.length ? rawList[qIdx] : <String, dynamic>{};
        throw ReadingPassageException(
          '[question file] Unknown question type\n'
          'Error: ${e.message}\n'
          'Raw JSON: ${const JsonEncoder.withIndent('  ').convert(rawGroup)}\n'
          "File: $questionPath\n"
          "series: $seriesId | test: $testId | part: $part | questionGroup: $questionGroup",
        );
      }
      if (e is TypeError) {
        final source = _identifySource(e.toString(), testPath, questionPath, answerPath, dictPath);
        throw ReadingPassageException(
          '[$source file] Type mismatch — unexpected JSON shape\n'
          "File: $source\n"
          'Error: $e\n'
          "series: $seriesId | test: $testId | part: $part | questionGroup: $questionGroup\n"
          'Tip: Check if the question type is handled by the parser.',
        );
      }
      final source = _identifySource(e.toString(), testPath, questionPath, answerPath, dictPath);
      throw ReadingPassageException(
        '[$source file] Unexpected error\n'
        "File: $source\n"
        'Error: $e\n'
        'Stack:\n$stack\n'
        "series: $seriesId | test: $testId | part: $part | questionGroup: $questionGroup",
      );
    }
  }

  static String _identifySource(String msg, String t, String q, String a, String d) {
    if (msg.contains(t)) return t;
    if (msg.contains(q)) return q;
    if (msg.contains(a)) return a;
    if (msg.contains(d)) return d;
    return t;
  }
}