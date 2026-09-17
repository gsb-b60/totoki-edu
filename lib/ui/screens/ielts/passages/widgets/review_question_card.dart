import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/ielts/models/review_item.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/select_summary_given_list.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/select_given_diagram.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/option_choice.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/checkbox_widget.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_answer.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_table.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/input_diagram.dart';

class ReviewQuestionCard extends StatefulWidget {
  final ReviewItem item;

  const ReviewQuestionCard({super.key, required this.item});

  @override
  State<ReviewQuestionCard> createState() => _ReviewQuestionCardState();
}

class _ReviewQuestionCardState extends State<ReviewQuestionCard> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isCorrect ? AppTheme.greenPrimary.withValues(alpha: 0.5) : AppTheme.redPrimary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.isCorrect
                  ? AppTheme.greenPrimary.withValues(alpha: 0.1)
                  : AppTheme.redPrimary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isCorrect ? AppTheme.greenPrimary : AppTheme.redPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q${item.index + 1}',
                    style: AppTheme.bodySmallStyle.copyWith(
                      color: AppTheme.darkBase,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Text(
                    item.typeLabel,
                    style: AppTheme.bodySmallStyle.copyWith(
                      color: AppTheme.lightText.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  item.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: item.isCorrect ? AppTheme.greenPrimary : AppTheme.redPrimary,
                  size: 28,
                ),
              ],
            ),
          ),

          // Question content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Text(
                  item.question.displayText,
                  style: AppTheme.bodyMediumStyle.copyWith(
                    color: AppTheme.lightText,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Review widget for this question type
                _buildReviewWidget(item),

                const SizedBox(height: 16),

                // Answer comparison
                _buildAnswerComparison(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewWidget(ReviewItem item) {
    final q = item.question;

    switch (q.type) {
      case 'select-flowchart-given-list':
        return SelectSummaryGivenList.buildReview(
          questionText: q.displayText,
          options: q.options,
          userSelected: item.userSelections,
          correctAnswers: q.answers,
        );

      case 'select-given-diagram':
        return SelectGivenDiagram.buildReview(
          questionText: q.displayText,
          options: q.options,
          userSelected: item.userSelections,
          correctAnswers: q.answers,
          imageAssetPath: q.imageAssetPath,
          diagramTitle: q.diagramTitle,
          constraint: q.constraint,
        );

      case 'option-abc':
      case 'option-true-false':
      case 'option-yes-no':
        return OptionChoice.buildReview(
          questionText: q.displayText,
          options: q.options,
          userSelected: item.userSelections.isNotEmpty ? item.userSelections[0] : null,
          correctAnswer: q.answers.isNotEmpty ? q.answers[0] : 0,
        );

      case 'checkbox':
        return CheckboxWidget.buildReview(
          questionText: q.displayText,
          options: q.options,
          userSelected: item.userSelections,
          correctAnswers: q.answers,
          quantity: q.answers.length,
        );

      case 'input-table':
        return InputTable.buildReview(
          headerText: q.displayText,
          tableHeaders: q.tableHeaders,
          tableCells: q.tableCells,
          tableInputCounts: q.tableInputCounts,
          userInputs: item.userTextInputs,
          correctAnswers: q.textAnswers,
          constraint: q.constraint,
        );

      case 'input-diagram':
        return InputDiagram.buildReview(
          questionText: q.displayText,
          imageAssetPath: q.imageAssetPath,
          diagramTitle: q.diagramTitle,
          userInputs: item.userTextInputs,
          correctAnswers: q.textAnswers,
          constraint: q.constraint,
        );

      default:
        if (q.type.startsWith('input-')) {
          return InputAnswer.buildReview(
            questionText: q.displayText,
            userInputs: item.userTextInputs,
            correctAnswers: q.textAnswers,
            constraint: q.constraint,
          );
        }
        if (q.type.startsWith('select-')) {
          return SelectSummaryGivenList.buildReview(
            questionText: q.displayText,
            options: q.options,
            userSelected: item.userSelections,
            correctAnswers: q.answers,
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orangeAccent.withAlpha(80)),
          ),
          child: Text(
            'Unhandled type in review: ${q.type}',
            style: AppTheme.bodySmallStyle.copyWith(color: Colors.orangeAccent),
          ),
        );
    }
  }

  Widget _buildAnswerComparison(ReviewItem item) {
    final q = item.question;
    final isInputType = q.type.startsWith('input-');

    if (isInputType) {
      return _buildInputComparison(item);
    } else {
      return _buildSelectionComparison(item);
    }
  }

  Widget _buildInputComparison(ReviewItem item) {
    final correctAnswers = item.correctTextAnswers;
    final userInputs = item.userTextInputs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_outlined, size: 16, color: AppTheme.lightText.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              'Your answers vs Correct answers',
              style: AppTheme.bodySmallStyle.copyWith(
                color: AppTheme.lightText.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(correctAnswers.length, (i) {
          final correct = i < correctAnswers.length ? correctAnswers[i] : '';
          final user = i < userInputs.length ? userInputs[i] : '';
          final isCorrect = user.trim().toLowerCase() == correct.trim().toLowerCase();
          final hasAnswer = user.trim().isNotEmpty;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasAnswer
                    ? (isCorrect ? AppTheme.greenPrimary : AppTheme.redPrimary)
                    : AppTheme.darkBorder,
                width: hasAnswer ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: hasAnswer
                        ? (isCorrect ? AppTheme.greenPrimary : AppTheme.redPrimary)
                        : AppTheme.darkBorder,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: hasAnswer
                        ? Icon(
                            isCorrect ? Icons.check : Icons.close,
                            size: 16,
                            color: AppTheme.darkBase,
                          )
                        : Text(
                            '${i + 1}',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.lightText.withValues(alpha: 0.5),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasAnswer) ...[
                        Text(
                          'Your answer: $user',
                          style: AppTheme.bodyMediumStyle.copyWith(
                            color: isCorrect ? AppTheme.greenPrimary : AppTheme.redPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        'Correct: $correct',
                        style: AppTheme.bodyMediumStyle.copyWith(
                          color: AppTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectionComparison(ReviewItem item) {
    final correctAnswers = item.correctSelections;
    final userSelections = item.userSelections;
    final options = item.question.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.quiz_outlined, size: 16, color: AppTheme.lightText.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              'Your selection vs Correct answer',
              style: AppTheme.bodySmallStyle.copyWith(
                color: AppTheme.lightText.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(options.length, (i) {
          final isCorrectAnswer = correctAnswers.contains(i);
          final isUserSelected = userSelections.contains(i);
          final hasUserAnswer = userSelections.isNotEmpty;

          Color borderColor;
          Color bgColor;
          if (!hasUserAnswer) {
            borderColor = AppTheme.darkBorder;
            bgColor = AppTheme.darkCard;
          } else if (isUserSelected && isCorrectAnswer) {
            borderColor = AppTheme.greenPrimary;
            bgColor = AppTheme.greenPrimary.withValues(alpha: 0.1);
          } else if (isUserSelected && !isCorrectAnswer) {
            borderColor = AppTheme.redPrimary;
            bgColor = AppTheme.redPrimary.withValues(alpha: 0.1);
          } else if (!isUserSelected && isCorrectAnswer) {
            borderColor = AppTheme.greenPrimary.withValues(alpha: 0.5);
            bgColor = AppTheme.greenPrimary.withValues(alpha: 0.05);
          } else {
            borderColor = AppTheme.darkBorder;
            bgColor = AppTheme.darkCard;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: hasUserAnswer || isCorrectAnswer ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isUserSelected
                        ? (isCorrectAnswer ? AppTheme.greenPrimary : AppTheme.redPrimary)
                        : (isCorrectAnswer ? AppTheme.greenPrimary.withValues(alpha: 0.3) : AppTheme.darkBorder),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCorrectAnswer && !isUserSelected ? AppTheme.greenPrimary : borderColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isUserSelected
                        ? Icon(
                            isCorrectAnswer ? Icons.check : Icons.close,
                            size: 16,
                            color: AppTheme.darkBase,
                          )
                        : (isCorrectAnswer
                            ? const Icon(Icons.check, size: 16, color: AppTheme.greenPrimary)
                            : Text(
                                '${i + 1}',
                                style: AppTheme.bodySmallStyle.copyWith(
                                  color: AppTheme.lightText.withValues(alpha: 0.5),
                                ),
                              )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    options[i],
                    style: AppTheme.bodyMediumStyle.copyWith(
                      color: isUserSelected
                          ? (isCorrectAnswer ? AppTheme.greenPrimary : AppTheme.redPrimary)
                          : (isCorrectAnswer ? AppTheme.greenPrimary : AppTheme.lightText),
                      fontWeight: isUserSelected || isCorrectAnswer ? FontWeight.w600 : FontWeight.normal,
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
          );
        }),
      ],
    );
  }
}