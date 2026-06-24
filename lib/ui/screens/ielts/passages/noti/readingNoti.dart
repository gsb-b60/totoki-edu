import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ParagraphGroup {
  final String displayText;
  final List<String> options;
  final List<int> answers;
  final List<String> textAnswers;
  final String type;
  final String? constraint;

  ParagraphGroup({
    required this.displayText,
    required this.options,
    required this.answers,
    this.textAnswers = const [],
    required this.type,
    this.constraint,
  });
}

class ReadingNoti extends ChangeNotifier {
  String title = "";
  String articleText = "";
  List<ParagraphGroup> questions = [];
  bool isLoading = false;
  Map<String, dynamic> _dictionary = {};

  String? lookupWord(String word) {
    final entry = _dictionary[word.toLowerCase()];
    return entry?["quick_def"] as String?;
  }

  Future<void> loadPassage({
    required int seriesId,
    required int testId,
    required int part,
    required int questionGroup,
  }) async {
    isLoading = true;
    notifyListeners();

    final testPath = "assets/ielts/test/$seriesId-$testId-$part.json";
    final questionPath = "assets/ielts/question/$seriesId-$testId-$part.json";
    final answerPath = "assets/ielts/answer/$seriesId-$testId.json";

    final results = await Future.wait([
      rootBundle.loadString(testPath),
      rootBundle.loadString(questionPath),
      rootBundle.loadString(answerPath),
      rootBundle.loadString("assets/ielts/jsondictionary.json"),
    ]);
    _dictionary = jsonDecode(results[3]) as Map<String, dynamic>;
    final data = jsonDecode(results[0]) as Map<String, dynamic>;
    final questionData = jsonDecode(results[1]) as Map<String, dynamic>;
    final answerData = jsonDecode(results[2]) as Map<String, dynamic>;
    final article = data["test_text"]["article"];
    title = article["title"] as String;
    final sections = article["sections"] as List;

    final buffer = StringBuffer();
    for (final section in sections) {
      for (final item in section["items"]) {
        for (final paragraph in item["items"]) {
          for (final sentence in paragraph["items"]) {
            buffer.write(sentence["sentence_raw"] as String);
            buffer.write(" ");
          }
          buffer.write("\n\n");
        }
      }
    }
    articleText = buffer.toString().trim();

    final readingAnswers = answerData["reading"] as List;
    final answerLookup = <int, int>{};
    final textAnswerLookup = <int, String>{};
    for (final ans in readingAnswers) {
      final qId = int.parse(ans["question_id"] as String);
      final correct = ans["correct_answer"] as String;
      if (correct.length == 1) {
        final code = correct.codeUnitAt(0);
        if (code >= 65 && code <= 90) {
          answerLookup[qId] = code - 65;
        } else {
          textAnswerLookup[qId] = correct;
        }
      } else {
        textAnswerLookup[qId] = correct;
      }
    }

    questions = [];
    final inputRegex = RegExp(r'<input(?:=[^>]*)?>');
    final qList = questionData["test_question"] as List;
    final qGroup = qList[questionGroup - 1];
    final type = qGroup["type"] as String;
    final body = qGroup["body"] as Map<String, dynamic>;

    if (type.startsWith("select-")) {
      final list = (body["list"] as List?)?.map((e) => e.toString().trim()).toList() ?? [];
      final items = body["items"] as List;
      int qNum = qGroup["start"] as int;

      for (final item in items) {
        if (item is Map && item["type"] == "example") continue;
        if (item is! String) continue;

        final matches = inputRegex.allMatches(item).toList();
        if (matches.isEmpty) continue;

        final displayText = item
            .replaceAll(inputRegex, '___')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        final answers = <int>[];
        for (int i = 0; i < matches.length; i++) {
          answers.add(answerLookup[qNum] ?? 0);
          qNum++;
        }

        questions.add(ParagraphGroup(
          displayText: displayText,
          options: List<String>.from(list),
          answers: answers,
          type: type,
        ));
      }
    } else if (type == "option-abc") {
      final items = body["items"] as List;
      int qNum = qGroup["start"] as int;

      for (final item in items) {
        if (item is! Map) continue;
        final title = item["title"] as String;
        final options = (item["options"] as List).map((e) => e.toString()).toList();

        questions.add(ParagraphGroup(
          displayText: title,
          options: options,
          answers: [answerLookup[qNum] ?? 0],
          type: type,
        ));
        qNum++;
      }
    } else if (type == "option-true-false" || type == "option-yes-no") {
      final items = body["items"] as List;
      const tfOptions = ["True", "False", "Not Given"];
      const ynOptions = ["Yes", "No", "Not Given"];
      final options = type == "option-true-false" ? tfOptions : ynOptions;
      int qNum = qGroup["start"] as int;

      for (final item in items) {
        if (item is! String) continue;

        final textAns = textAnswerLookup[qNum]?.toUpperCase() ?? "";
        int answerIdx;
        if (textAns == "TRUE" || textAns == "YES") {
          answerIdx = 0;
        } else if (textAns == "FALSE" || textAns == "NO") {
          answerIdx = 1;
        } else {
          answerIdx = 2;
        }

        questions.add(ParagraphGroup(
          displayText: item,
          options: List<String>.from(options),
          answers: [answerIdx],
          type: type,
        ));
        qNum++;
      }
    } else if (type == "checkbox") {
      final title = body["title"] as String;
      final opts = (body["options"] as List).map((e) => e.toString()).toList();
      final quantity = qGroup["desc"]["quantity"] as int;
      int qNum = qGroup["start"] as int;

      final answers = <int>[];
      for (int i = 0; i < quantity; i++) {
        answers.add(answerLookup[qNum] ?? 0);
        qNum++;
      }

      questions.add(ParagraphGroup(
        displayText: title,
        options: opts,
        answers: answers,
        type: type,
      ));
    } else if (type.startsWith("input-")) {
      final items = body["items"] as List;
      final constraint = qGroup["desc"]?["constraint"] as String?;
      int qNum = qGroup["start"] as int;

      for (final item in items) {
        if (item is Map && item["type"] == "example") continue;

        String text;
        if (item is String) {
          text = item;
        } else if (item is Map) {
          text = (item["title"] as String?) ?? (item["prefix"] as String?) ?? "";
        } else {
          continue;
        }

        final matches = inputRegex.allMatches(text).toList();
        if (matches.isEmpty) continue;

        final displayText = text
            .replaceAll(inputRegex, '___')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        final textAnswers = <String>[];
        for (int i = 0; i < matches.length; i++) {
          textAnswers.add(textAnswerLookup[qNum] ?? "");
          qNum++;
        }

        questions.add(ParagraphGroup(
          displayText: displayText,
          options: [],
          answers: [],
          textAnswers: textAnswers,
          type: type,
          constraint: constraint,
        ));
      }
    }

    isLoading = false;
    notifyListeners();
  }
}
