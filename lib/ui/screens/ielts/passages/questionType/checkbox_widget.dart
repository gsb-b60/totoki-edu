import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class CheckboxWidget extends StatelessWidget {
  final String questionText;
  final List<String> options;
  final List<int?> selected;
  final int quantity;
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final void Function(int index, int option) onSelect;

  const CheckboxWidget({
    super.key,
    required this.questionText,
    required this.options,
    required this.selected,
    required this.quantity,
    required this.answered,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final chosen = selected.whereType<int>().toSet();
    final remaining = quantity - chosen.length;

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
                if (!answered) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Select $quantity options (${remaining > 0 ? "$remaining remaining" : "done"})",
                    style: AppTheme.captionStyle.copyWith(
                      color: remaining > 0 ? Colors.orangeAccent : AppTheme.greenPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ...List.generate(options.length, (i) {
                  final isSelected = chosen.contains(i);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: answered
                          ? null
                          : () {
                              final slot = selected.indexOf(i);
                              if (slot >= 0) {
                                onSelect(slot, -1);
                              } else if (remaining > 0) {
                                final emptySlot = selected.indexOf(null);
                                if (emptySlot >= 0) {
                                  onSelect(emptySlot, i);
                                }
                              }
                            },
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
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected ? AppTheme.greenPrimary : AppTheme.darkBorder,
                                  width: 2,
                                ),
                                color: isSelected ? AppTheme.greenPrimary : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${String.fromCharCode(65 + i)}. ${options[i]}",
                                style: AppTheme.bodyLargeStyle.copyWith(
                                  color: isSelected ? AppTheme.greenPrimary : AppTheme.lightText,
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
