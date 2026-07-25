import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    super.key,
    required this.right,
    required this.onPressed,
    required this.answer,
  });
  final bool right;
  final String answer;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  right ? Icons.check_circle_rounded : Icons.cancel,
                  color: right ? AppTheme.greenPrimary : AppTheme.redPrimary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  right ? "Great job!" : "Incorrect",
                  style: AppTheme.sectionHeaderStyle.copyWith(
                    color: right ? AppTheme.greenPrimary : AppTheme.redPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!right) ...[
              const SizedBox(height: 16),
              Text(
                "Correct answer:",
                style: AppTheme.bodyMediumStyle.copyWith(
                  color: AppTheme.lightText.withValues(alpha:0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                answer,
                style: AppTheme.bodyLargeStyle.copyWith(
                  color: AppTheme.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: right
                      ? AppTheme.greenPrimary
                      : AppTheme.redPrimary,
                ),
                child: Text(
                  right ? "CONTINUE" : "GOT IT",
                  style: AppTheme.bodyLargeStyle.copyWith(
                    color: AppTheme.darkBase,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


