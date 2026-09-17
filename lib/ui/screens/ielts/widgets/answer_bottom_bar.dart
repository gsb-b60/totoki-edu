import 'package:flutter/material.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/nav_btn.dart';
import 'package:totoki_extract/ui/screens/ielts/widgets/submit_btn.dart';

class AnswerBottomBar extends StatelessWidget {
  final int currentParagraph;
  final int totalParagraphs;
  final bool answered;
  final bool allParagraphsComplete;
  final bool currentIsSubmitted;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;
  final VoidCallback? onDismiss;

  const AnswerBottomBar({
    super.key,
    required this.currentParagraph,
    required this.totalParagraphs,
    required this.answered,
    required this.allParagraphsComplete,
    required this.currentIsSubmitted,
    this.onBack,
    this.onNext,
    this.onSubmit,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentParagraph == totalParagraphs - 1;
    final isFirst = currentParagraph == 0;

    return Row(
      children: [
        Expanded(
          child: NavBtn(
            label: "BACK",
            icon: Icons.arrow_back_ios,
            onTap: isFirst ? null : onBack,
          ),
        ),
        const SizedBox(width: 12),
        if (!answered)
          Expanded(
            flex: 2,
            child: SubmitBtn(
              active: allParagraphsComplete && !currentIsSubmitted,
              onTap: allParagraphsComplete && !currentIsSubmitted ? onSubmit : null,
            ),
          )
        else
          Expanded(
            flex: 2,
            child: SubmitBtn(
              active: true,
              onTap: onDismiss,
              label: "DISMISS",
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: NavBtn(
            label: "NEXT",
            icon: Icons.arrow_forward_ios,
            onTap: isLast ? null : onNext,
            trailing: true,
          ),
        ),
      ],
    );
  }
}
