import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class CheckBtnVertical extends StatelessWidget {
  final bool isChecked;
  final VoidCallback? onCheck;
  const CheckBtnVertical({super.key, required this.isChecked, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isChecked ? onCheck : null,
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isChecked ? AppTheme.greenPrimary : AppTheme.darkCard,
          boxShadow: isChecked ? [
            BoxShadow(
              color: AppTheme.greenPrimary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Center(
          child: Text(
            "CHECK",
            style: AppTheme.bodyLargeStyle.copyWith(
              color: isChecked ? AppTheme.darkBase : AppTheme.lightText.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}


