import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class SubmitBtn extends StatelessWidget {
  final bool active;
  final VoidCallback? onTap;
  final String label;

  const SubmitBtn({super.key, required this.active, this.onTap, this.label = "SUBMIT"});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active ? AppTheme.greenPrimary : AppTheme.darkCard,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.bodyLargeStyle.copyWith(
              color: active ? AppTheme.darkBase : AppTheme.lightText.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
