import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';
import 'package:totoki_extract/features/ielts/parsers/answer_parser.dart';
import 'package:totoki_extract/features/ielts/parsers/question_normalizer.dart';
import 'package:totoki_extract/features/ielts/parsers/question_parser.dart';

void main( ) {
  TestWidgetsFlutterBinding.ensureInitialized();


  test('Counter value should be incremented', ()async {
    await QuestionParserTest.Parser();
  });

}

class QuestionParserTest {
  QuestionParserTest() {}

  static Parser() async { 

    print("check this testing intergration ");
    List<ParagraphGroup> questions = [];
    final seriesId = 1;
    final testId = 1;
    final part = 1;
    int questionGroup = 1;

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

      questionData = jsonDecode(results[1]) as Map<String, dynamic>;
      final answerData = jsonDecode(results[2]) as Map<String, dynamic>;

      final answers = AnswerParser.parse(answerData["reading"] as List?);
      final qList = questionData["test_question"] as List? ?? [];

      final normalized = QuestionNormalizer.normalizeGroup(
        qList[questionGroup - 1] as Map<String, dynamic>,
      );
      questions = QuestionParser.parse(
        qGroup: normalized,
        answerLookup: answers.optionLookup,
        textAnswerLookup: answers.textLookup,
        seriesId: seriesId,
      );
      print(questions.length);
    } catch (e) {

      print(e);
      rethrow;
    }
  }
}
