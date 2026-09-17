import 'package:totoki_extract/features/ielts/models/article_fragment.dart';
import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';

class ReadingPassageResult {
  final String title;
  final List<ArticleFragment> fragments;
  final String articleText;
  final List<ParagraphGroup> questions;
  final Map<String, dynamic> dictionary;

  const ReadingPassageResult({
    required this.title,
    required this.fragments,
    required this.articleText,
    required this.questions,
    required this.dictionary,
  });

  static const empty = ReadingPassageResult(
    title: '',
    fragments: [],
    articleText: '',
    questions: [],
    dictionary: {},
  );
}