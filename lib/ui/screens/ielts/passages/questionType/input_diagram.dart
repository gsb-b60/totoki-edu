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

  static Widget buildReview({
    required String questionText,
    required String? imageAssetPath,
    required String? diagramTitle,
    required List<String> userInputs,
    required List<String> correctAnswers,
    String? constraint,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (constraint != null) ...[
            Text(
              constraint,
              style: AppTheme.captionStyle.copyWith(color: Colors.orangeAccent, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
          if (questionText.isNotEmpty) ...[
            Text(
              questionText,
              style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
          ],
          if (diagramTitle != null && diagramTitle.isNotEmpty) ...[
            Text(
              diagramTitle,
              style: AppTheme.sectionHeaderStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (imageAssetPath != null) ...[
            PictureViewer(imageAssetPath: imageAssetPath),
            const SizedBox(height: 16),
          ],
          for (int i = 0; i < userInputs.length; i++)
            _buildReviewField(i, userInputs, correctAnswers),
        ],
      ),
    );
  }

  static Widget _buildReviewField(int index, List<String> userInputs, List<String> correctAnswers) {
    final user = index < userInputs.length ? userInputs[index] : '';
    final correct = index < correctAnswers.length ? correctAnswers[index] : '';
    final isCorrect = user.trim().toLowerCase() == correct.trim().toLowerCase();
    final hasAnswer = user.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              "${index + 1}.",
              style: AppTheme.bodyLargeStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.greenPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: hasAnswer
                      ? (isCorrect ? AppTheme.greenPrimary : AppTheme.redPrimary)
                      : AppTheme.darkBorder,
                  width: hasAnswer ? 2 : 1,
                ),
                color: hasAnswer
                    ? (isCorrect ? AppTheme.greenPrimary.withValues(alpha: 0.1) : AppTheme.redPrimary.withValues(alpha: 0.1))
                    : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(
                hasAnswer ? user : correct,
                style: TextStyle(
                  color: hasAnswer
                      ? (isCorrect ? AppTheme.greenPrimary : AppTheme.redPrimary)
                      : AppTheme.greenPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
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
