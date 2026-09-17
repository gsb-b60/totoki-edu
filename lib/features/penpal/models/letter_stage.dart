class LetterStage {
  final int stageNumber;
  final String incomingLetter;
  final List<String> requiredKeywords;
  final String keywordRegex;
  final String successReply;
  final String failHint;

  const LetterStage({
    required this.stageNumber,
    required this.incomingLetter,
    required this.requiredKeywords,
    required this.keywordRegex,
    required this.successReply,
    required this.failHint,
  });
}