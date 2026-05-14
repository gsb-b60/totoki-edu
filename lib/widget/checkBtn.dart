import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class CheckBtn extends StatelessWidget {
  bool isChecked;
  VoidCallback? onCheck;
  CheckBtn({super.key, required this.isChecked, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isChecked ? onCheck : null,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: 70,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            bottom: BorderSide(
              color: isChecked ? AppTheme.greenAccent : Colors.transparent,
              width: 6,
            ),
          ),
          color: isChecked ? AppTheme.greenPrimary : AppTheme.darkCard,
        ),
        child: Center(
          child: Text(
            "Check",
            style: TextStyle(
              color: AppTheme.darkBase,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

