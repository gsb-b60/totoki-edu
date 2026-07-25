import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/picture_viewer.dart';

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

  void _showOptionsDialog(BuildContext context, int blankIdx) {
    final usedByOthers = <int>{...usedOptionIndices};
    for (int i = 0; i < selected.length; i++) {
      if (i != blankIdx && selected[i] != null) {
        usedByOthers.add(selected[i]!);
      }
    }

    final available = <int>[];
    for (int i = 0; i < options.length; i++) {
      if (!usedByOthers.contains(i) || (selected.length > blankIdx && selected[blankIdx] == i)) {
        available.add(i);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text('Select an option', style: AppTheme.sectionHeaderStyle),
        children: available.map((i) {
          final isSelected = selected.length > blankIdx && selected[blankIdx] == i;
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              onSelect(blankIdx, i);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                options[i],
                style: AppTheme.bodyLargeStyle.copyWith(
                  color: isSelected ? AppTheme.greenPrimary : AppTheme.lightText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

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
                Text(
                  "Question $questionIndex/$totalQuestions",
                  style: AppTheme.captionStyle.copyWith(fontSize: 13),
                ),
                if (constraint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    constraint!,
                    style: AppTheme.captionStyle.copyWith(color: Colors.orangeAccent, fontSize: 12),
                  ),
                ],
                if (questionText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    questionText,
                    style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 14),
                  ),
                ],
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
                  PictureViewer(imageAssetPath: imageAssetPath!),
                ],
                const SizedBox(height: 16),
                for (int i = 0; i < selected.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            "${i + 1}.",
                            style: AppTheme.bodyLargeStyle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.greenPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: answered
                              ? _buildAnsweredField(i)
                              : _buildDropdownField(context, i),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnsweredField(int index) {
    final sel = index < selected.length ? selected[index] : null;
    final text = sel != null ? options[sel] : "";
    return Text(
      text.isEmpty ? " ___ " : text,
      style: TextStyle(
        color: text.isEmpty ? Colors.redAccent : AppTheme.greenPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, int index) {
    final sel = index < selected.length ? selected[index] : null;
    return SizedBox(
      height: 32,
      child: GestureDetector(
        onTap: () => _showOptionsDialog(context, index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: sel != null ? AppTheme.greenPrimary : AppTheme.darkBorder,
              width: sel != null ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  sel != null ? options[sel] : " ___ ",
                  style: const TextStyle(
                    color: AppTheme.greenPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: AppTheme.greenPrimary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
