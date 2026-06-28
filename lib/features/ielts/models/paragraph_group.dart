class ParagraphGroup {
  final String displayText;
  final List<String> options;
  final List<int> answers;
  final List<String> textAnswers;
  final String type;
  final String? constraint;
  final List<String>? rowLabels;

  final String? imageAssetPath;
  final String? diagramTitle;

  ParagraphGroup({
    required this.displayText,
    required this.options,
    required this.answers,
    this.textAnswers = const [],
    required this.type,
    this.constraint,
    this.rowLabels,
    this.imageAssetPath,
    this.diagramTitle,
  });
}
