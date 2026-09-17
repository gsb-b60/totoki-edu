import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class OptionChoice extends StatelessWidget {
  final String questionText;
  final List<String> options;
  final int? selected;
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final void Function(int) onSelect;

  const OptionChoice({
    super.key,
    required this.questionText,
    required this.options,
    required this.selected,
    required this.answered,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onSelect,
  });

  static Widget buildReview({
    required String questionText,
    required List<String> options,
    required int? userSelected,
    required int correctAnswer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          questionText,
          style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        ...List.generate(options.length, (i) {
          final isUserSelected = userSelected == i;
          final isCorrectAnswer = correctAnswer == i;
          final hasAnswer = userSelected != null;

          Color borderColor;
          Color bgColor;
          Color textColor;
          Color iconColor;
          Widget? icon;

          if (!hasAnswer) {
            borderColor = AppTheme.darkBorder;
            bgColor = Colors.transparent;
            textColor = AppTheme.lightText;
            iconColor = AppTheme.darkBorder;
            icon = Center(
              child: Text(
                String.fromCharCode(65 + i),
                style: TextStyle(
                  color: AppTheme.lightText.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );
          } else if (isUserSelected && isCorrectAnswer) {
            borderColor = AppTheme.greenPrimary;
            bgColor = AppTheme.darkCard;
            textColor = AppTheme.greenPrimary;
            iconColor = AppTheme.greenPrimary;
            icon = const Icon(Icons.check, size: 16, color: Colors.white);
          } else if (isUserSelected && !isCorrectAnswer) {
            borderColor = AppTheme.redPrimary;
            bgColor = AppTheme.darkCard;
            textColor = AppTheme.redPrimary;
            iconColor = AppTheme.redPrimary;
            icon = const Icon(Icons.close, size: 16, color: Colors.white);
          } else if (!isUserSelected && isCorrectAnswer) {
            borderColor = AppTheme.greenPrimary.withValues(alpha: 0.5);
            bgColor = AppTheme.greenPrimary.withValues(alpha: 0.05);
            textColor = AppTheme.greenPrimary;
            iconColor = AppTheme.greenPrimary;
            icon = const Icon(Icons.check, size: 16, color: AppTheme.greenPrimary);
          } else {
            borderColor = AppTheme.darkBorder;
            bgColor = Colors.transparent;
            textColor = AppTheme.lightText;
            iconColor = AppTheme.darkBorder;
            icon = Center(
              child: Text(
                String.fromCharCode(65 + i),
                style: TextStyle(
                  color: AppTheme.lightText.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: (hasAnswer || isCorrectAnswer) ? 2 : 1.5),
                color: bgColor,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: iconColor, width: 2),
                      color: (isUserSelected && isCorrectAnswer) ? AppTheme.greenPrimary :
                             (isUserSelected && !isCorrectAnswer) ? AppTheme.redPrimary :
                             Colors.transparent,
                    ),
                    child: icon,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      options[i],
                      style: AppTheme.bodyLargeStyle.copyWith(
                        color: textColor,
                        fontWeight: (isUserSelected || isCorrectAnswer) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCorrectAnswer && !isUserSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.greenPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MISSED',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: AppTheme.darkBase,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Question $questionIndex/$totalQuestions",
          style: AppTheme.captionStyle.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionText,
                  style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),
                ...List.generate(options.length, (i) {
                  final isSelected = selected == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: answered ? null : () => onSelect(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.greenPrimary : AppTheme.darkBorder,
                            width: isSelected ? 2 : 1.5,
                          ),
                          color: isSelected ? AppTheme.darkCard : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.greenPrimary : AppTheme.darkBorder,
                                  width: 2,
                                ),
                                color: isSelected ? AppTheme.greenPrimary : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + i),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.lightText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                options[i],
                                style: AppTheme.bodyLargeStyle.copyWith(
                                  color: isSelected ? AppTheme.greenPrimary : AppTheme.lightText,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
