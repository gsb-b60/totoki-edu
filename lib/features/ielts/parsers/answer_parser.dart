class AnswerParser {
  static ({Map<int, int> optionLookup, Map<int, String> textLookup}) parse(
    List? readingAnswers,
  ) {
    final optionLookup = <int, int>{};
    final textLookup = <int, String>{};

    if (readingAnswers == null) return (optionLookup: optionLookup, textLookup: textLookup);

    for (final ans in readingAnswers) {
      final qIdStr = ans["question_id"] as String?;
      final correct = ans["correct_answer"] as String?;
      if (qIdStr == null || correct == null) continue;
      final qId = int.parse(qIdStr);
      if (correct.length == 1) {
        final code = correct.codeUnitAt(0);
        if (code >= 65 && code <= 90) {
          optionLookup[qId] = code - 65;
        } else {
          textLookup[qId] = correct;
        }
      } else {
        textLookup[qId] = correct;
      }
    }

    return (optionLookup: optionLookup, textLookup: textLookup);
  }
}
