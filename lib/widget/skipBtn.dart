import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class SkipBtn extends StatelessWidget {
  const SkipBtn({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.redPrimary,
          foregroundColor: AppTheme.darkBase,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "SKIP",
          style: AppTheme.bodySmallStyle.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
