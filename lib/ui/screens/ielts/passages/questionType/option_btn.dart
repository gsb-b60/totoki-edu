import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';

class OptionBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const OptionBtn({super.key, required this.label, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: isSelected ? AppTheme.greenPrimary : AppTheme.darkBorder, width: 2),
          backgroundColor: isSelected ? AppTheme.darkCard : AppTheme.darkSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          label,
          style: AppTheme.bodyLargeStyle.copyWith(
            color: isSelected ? AppTheme.greenPrimary : AppTheme.lightText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
