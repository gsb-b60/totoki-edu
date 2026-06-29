import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class NavBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool trailing;

  const NavBtn({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.trailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppTheme.greenPrimary : AppTheme.darkBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: trailing ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!trailing) Icon(icon, size: 16, color: active ? AppTheme.greenPrimary : AppTheme.darkBorder),
            if (!trailing) const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.bodyLargeStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: active ? AppTheme.greenPrimary : AppTheme.darkBorder,
              ),
            ),
            if (trailing) const SizedBox(width: 4),
            if (trailing) Icon(icon, size: 16, color: active ? AppTheme.greenPrimary : AppTheme.darkBorder),
          ],
        ),
      ),
    );
  }
}
