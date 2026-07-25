import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class InputAnswer extends StatelessWidget {
  final String questionText;
  final List<String> inputs;
  final String? constraint;
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final void Function(int index, String value) onChanged;

  const InputAnswer({
    super.key,
    required this.questionText,
    required this.inputs,
    this.constraint,
    required this.answered,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final parts = questionText.split('___');

    return Column(
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
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 16, height: 1.5),
                children: _buildSpans(parts),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<InlineSpan> _buildSpans(List<String> parts) {
    final spans = <InlineSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i]));
      }
      if (i < parts.length - 1) {
        final idx = i;
        if (idx < inputs.length) {
          if (answered) {
            spans.add(TextSpan(
              text: inputs[idx].isEmpty ? " ___ " : inputs[idx],
              style: TextStyle(
                color: inputs[idx].isEmpty ? Colors.redAccent : AppTheme.greenPrimary,
                fontWeight: FontWeight.bold,
              ),
            ));
          } else {
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SizedBox(
                width: 120,
                height: 32,
                child: TextField(
                  onChanged: (v) => onChanged(idx, v),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppTheme.greenPrimary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppTheme.darkBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppTheme.greenPrimary, width: 2),
                    ),
                  ),
                  style: const TextStyle(
                    color: AppTheme.greenPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ));
          }
        }
      }
    }
    return spans;
  }
}
