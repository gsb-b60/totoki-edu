import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/ui/screens/ielts/passages/questionType/select_summary_given_list.dart';

class SelectGivenDiagram extends StatelessWidget {
  final String questionText;
  final List<String> options;
  final List<int?> selected;
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final Set<int> usedOptionIndices;
  final void Function(int blankIndex, int optionIndex) onSelect;
  final String? imageAssetPath;
  final String? diagramTitle;
  final String? constraint;

  const SelectGivenDiagram({
    super.key,
    required this.questionText,
    required this.options,
    required this.selected,
    required this.answered,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onSelect,
    this.usedOptionIndices = const {},
    this.imageAssetPath,
    this.diagramTitle,
    this.constraint,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (diagramTitle != null && diagramTitle!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    diagramTitle!,
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (imageAssetPath != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imageAssetPath!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SelectSummaryGivenList(
                  questionText: questionText,
                  options: options,
                  selected: selected,
                  answered: answered,
                  questionIndex: questionIndex,
                  totalQuestions: totalQuestions,
                  usedOptionIndices: usedOptionIndices,
                  onSelect: onSelect,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
