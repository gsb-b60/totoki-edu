import 'package:totoki_extract/features/ielts/models/paragraph_group.dart';

class ReviewItem {
  final int index;
  final ParagraphGroup question;
  final List<int?> userSelections;
  final List<String> userTextInputs;
  final List<int> correctSelections;
  final List<String> correctTextAnswers;
  final bool isCorrect;

  const ReviewItem({
    required this.index,
    required this.question,
    required this.userSelections,
    required this.userTextInputs,
    required this.correctSelections,
    required this.correctTextAnswers,
    required this.isCorrect,
  });

  String get typeLabel {
    final t = question.type;
    if (t.startsWith('select-')) return 'SELECT';
    if (t.startsWith('option-')) return 'MULTIPLE CHOICE';
    if (t == 'checkbox') return 'CHECKBOX';
    if (t.startsWith('input-')) return 'INPUT';
    return t.toUpperCase();
  }

  int get userAnsweredCount {
    int count = 0;
    for (final s in userSelections) {
      if (s != null) count++;
    }
    for (final t in userTextInputs) {
      if (t.trim().isNotEmpty) count++;
    }
    return count;
  }

  int get totalAnswerCount {
    return correctSelections.length + correctTextAnswers.length;
  }
}