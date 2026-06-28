import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class SelectSummaryGivenList extends StatefulWidget {
  final String questionText;
  final List<String> options;
  final List<int?> selected;
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final Set<int> usedOptionIndices;
  final void Function(int blankIndex, int optionIndex) onSelect;

  const SelectSummaryGivenList({
    super.key,
    required this.questionText,
    required this.options,
    required this.selected,
    required this.answered,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onSelect,
    this.usedOptionIndices = const {},
  });

  @override
  State<SelectSummaryGivenList> createState() => _SelectSummaryGivenListState();
}

class _SelectSummaryGivenListState extends State<SelectSummaryGivenList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Question ${widget.questionIndex}/${widget.totalQuestions}",
          style: AppTheme.captionStyle.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildSummaryText()),
      ],
    );
  }

  Widget _buildSummaryText() {
    final parts = widget.questionText.split('___');
    return SingleChildScrollView(
      child: RichText(
        text: TextSpan(
          style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 16, height: 1.5),
          children: _buildSpans(parts),
        ),
      ),
    );
  }

  List<InlineSpan> _buildSpans(List<String> parts) {
    final spans = <InlineSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i]));
      }
      if (i < parts.length - 1) {
        final sel = widget.selected.length > i ? widget.selected[i] : null;
        if (sel != null) {
          if (!widget.answered) {
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => _showOptionsDialog(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.greenPrimary, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.options[sel],
                          style: const TextStyle(
                            color: AppTheme.greenPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: AppTheme.greenPrimary, size: 20),
                    ],
                  ),
                ),
              ),
            ));
          } else {
            spans.add(TextSpan(
              text: widget.options[sel],
              style: const TextStyle(
                color: AppTheme.greenPrimary,
                fontWeight: FontWeight.bold,
              ),
            ));
          }
        } else if (!widget.answered) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => _showOptionsDialog(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.greenPrimary, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Flexible(
                        child: Text(
                          ' ___ ',
                          style: TextStyle(
                            color: AppTheme.greenPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: AppTheme.greenPrimary, size: 20),
                    ],
                  ),
              ),
            ),
          ));
        } else {
          spans.add(const TextSpan(
            text: ' ___ ',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ));
        }
      }
    }
    return spans;
  }

  void _showOptionsDialog(int blankIdx) {
    final usedByOthers = <int>{...widget.usedOptionIndices};
    for (int i = 0; i < widget.selected.length; i++) {
      if (i != blankIdx && widget.selected[i] != null) {
        usedByOthers.add(widget.selected[i]!);
      }
    }

    final available = <int>[];
    for (int i = 0; i < widget.options.length; i++) {
      if (!usedByOthers.contains(i) || (widget.selected.length > blankIdx && widget.selected[blankIdx] == i)) {
        available.add(i);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text(
          'Select an option',
          style: AppTheme.sectionHeaderStyle,
        ),
        children: available.map((i) {
          final isSelected = widget.selected.length > blankIdx && widget.selected[blankIdx] == i;
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onSelect(blankIdx, i);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                widget.options[i],
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
}
