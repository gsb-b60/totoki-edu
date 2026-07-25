import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/picture_viewer.dart';

class InputDiagram extends StatelessWidget {
  final String questionText;
  final String? imageAssetPath;
  final String? diagramTitle;
  final List<String> inputs;
  final String? constraint;
  final bool answered;
  final int questionIndex;
  final int totalQuestions;
  final void Function(int index, String value) onChanged;

  const InputDiagram({
    super.key,
    required this.questionText,
    this.imageAssetPath,
    this.diagramTitle,
    required this.inputs,
    this.constraint,
    required this.answered,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onChanged,
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
                for (int i = 0; i < inputs.length; i++)
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
                              : _buildInputField(i),
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
    final text = index < inputs.length ? inputs[index] : "";
    return Text(
      text.isEmpty ? " ___ " : text,
      style: TextStyle(
        color: text.isEmpty ? Colors.redAccent : AppTheme.greenPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildInputField(int index) {
    return SizedBox(
      height: 32,
      child: TextField(
        onChanged: (v) => onChanged(index, v),
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
    );
  }
}
