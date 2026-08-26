import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totoki_extract/features/ielts/models/article_fragment.dart';
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';
import 'package:totoki_extract/features/ielts/parsers/answer_parser.dart';
import 'package:totoki_extract/features/ielts/parsers/article_parser.dart';
import 'package:totoki_extract/features/ielts/parsers/question_normalizer.dart';
import 'package:totoki_extract/features/ielts/parsers/question_parser.dart';

void main ()
{

  TestWidgetsFlutterBinding.ensureInitialized();
  test("",() async
  {
    // final testPath= "assets/ielts/test/$seriesId-$testId-$part.json";
    // print("helloworld");
    await Parser.loopThroughTest();
  });


}

class Parser
{
  Parser(){}
  static loopThroughTest() async
  {
    var list= [];
    for(var seriresID =1 ;  seriresID < 20;seriresID++)
    {
      for(var testID= 1; testID<4;testID++)
      {
        for(var part=1; part<3; part++)
        {
          list.add(await Parser.parseFromJson(seriresID, testID, part, 1));
        } 
      }
    }
    final success = (list.where((n)=>n==true)).length;
    print("total ${list.length} success case ${success} fail case ${list.length- success}");
  }



  static parseFromJson(seriesID, testID,part, questionGroup)
  async {
    List<ParagraphGroup> questions = [];
    List<ArticleFragment> articleFragments = [];
    String title = "";
    String articleText = "";
    final testPath = "assets/ielts/test/$seriesID-$testID-$part.json";
    final questionPath = "assets/ielts/question/$seriesID-$testID-$part.json";
    final answerPath = "assets/ielts/answer/$seriesID-$testID.json";
    final dictPath = "assets/ielts/jsondictionary.json";
    Map<String, dynamic>? questionData;
    try {
      final results = await Future.wait([
        rootBundle.loadString(testPath),
        rootBundle.loadString(questionPath),
        rootBundle.loadString(answerPath),
        rootBundle.loadString(dictPath),
      ]);
      final data = jsonDecode(results[0]) as Map<String, dynamic>;
      questionData = jsonDecode(results[1]) as Map<String, dynamic>;
      final answerData = jsonDecode(results[2]) as Map<String, dynamic>;
      final _dictionary = jsonDecode(results[3]) as Map<String, dynamic>;

      final article = ArticleParser.parse(data, seriesID);
      title = article.title;
      articleFragments = article.fragments;
      articleText = article.articleText;
      if(title=="?")
      {
        return false;
      }
      //print("found the "+title);

      // final answers = AnswerParser.parse(answerData["reading"] as List?);
      // final qList = questionData["test_question"] as List? ?? [];

      // final normalized = QuestionNormalizer.normalizeGroup(
      //   qList[questionGroup - 1] as Map<String, dynamic>,
      // );
      // questions = QuestionParser.parse(
      //   qGroup: normalized,
      //   answerLookup: answers.optionLookup,
      //   textAnswerLookup: answers.textLookup,
      //   seriesId: seriesID,
      // );
      // print(questions.length);
      return true;
    } catch (e) {

      print(e);
      return false;
    }
  }

  static parseQuestionFromJson(seriesID, testID,part, questionGroup)
  async {
    List<ParagraphGroup> questions = [];
    List<ArticleFragment> articleFragments = [];
    String title = "";
    String articleText = "";
    final testPath = "assets/ielts/test/$seriesID-$testID-$part.json";
    final questionPath = "assets/ielts/question/$seriesID-$testID-$part.json";
    final answerPath = "assets/ielts/answer/$seriesID-$testID.json";
    final dictPath = "assets/ielts/jsondictionary.json";
    Map<String, dynamic>? questionData;
    try {
      final results = await Future.wait([
        rootBundle.loadString(testPath),
        rootBundle.loadString(questionPath),
        rootBundle.loadString(answerPath),
        rootBundle.loadString(dictPath),
      ]);
      final data = jsonDecode(results[0]) as Map<String, dynamic>;
      questionData = jsonDecode(results[1]) as Map<String, dynamic>;
      final answerData = jsonDecode(results[2]) as Map<String, dynamic>;
      final _dictionary = jsonDecode(results[3]) as Map<String, dynamic>;

      final article = ArticleParser.parse(data, seriesID);
      title = article.title;
      articleFragments = article.fragments;
      articleText = article.articleText;

      final answers = AnswerParser.parse(answerData["reading"] as List?);
      final qList = questionData["test_question"] as List? ?? [];

      final normalized = QuestionNormalizer.normalizeGroup(
        qList[questionGroup - 1] as Map<String, dynamic>,
      );
      questions = QuestionParser.parse(
        qGroup: normalized,
        answerLookup: answers.optionLookup,
        textAnswerLookup: answers.textLookup,
        seriesId: seriesID,
      );
      print(questions.length);
      return true;
    } catch (e) {

      print(e);
      return false;
    }
  }
}