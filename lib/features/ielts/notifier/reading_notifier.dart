import 'package:flutter/material.dart';
import 'package:totoki_extract/features/ielts/models/article_fragment.dart';
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';
import 'package:totoki_extract/features/ielts/parsers/reading_passage_parser.dart';

class ReadingNoti extends ChangeNotifier {
  String title = "";
  String articleText = "";
  List<ArticleFragment> articleFragments = [];
  List<ParagraphGroup> questions = [];
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic> _dictionary = {};

  bool get hasError => errorMessage != null;

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

    try {
      final result = await ReadingPassageParser.parse(
        seriesId: seriesId,
        testId: testId,
        part: part,
        questionGroup: questionGroup,
      );

      title = result.title;
      articleFragments = result.fragments;
      articleText = result.articleText;
      questions = result.questions;
      _dictionary = result.dictionary;
      errorMessage = null;
    } on ReadingPassageException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}