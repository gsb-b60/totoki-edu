class ParagraphGroup {
  final String displayText;
  final List<String> options;
  final List<int> answers;
  final List<String> textAnswers;
  final String type;
  final String? constraint;

  final String? imageAssetPath;
  final String? diagramTitle;

  final List<String>? tableHeaders;
  final List<List<String>>? tableCells;
  final List<List<int>>? tableInputCounts;

  ParagraphGroup({
    required this.displayText,
    required this.options,
    required this.answers,
    this.textAnswers = const [],
    required this.type,
    this.constraint,
    this.imageAssetPath,
    this.diagramTitle,
    this.tableHeaders,
    this.tableCells,
    this.tableInputCounts,
  });
  
}
