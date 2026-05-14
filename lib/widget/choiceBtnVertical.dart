import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class ChoiceBtnVertical extends StatelessWidget {
  String value;
  bool isSelected;
  VoidCallback? onPressed;
  ChoiceBtnVertical({
    super.key,
    required this.isSelected,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SizedBox(
        width: 240,
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: isSelected ? AppTheme.greenMuted : AppTheme.darkCard,
              width: 4,
            ),
            backgroundColor: isSelected
                ? AppTheme.darkSurface
                : AppTheme.darkBase,
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? AppTheme.greenMuted : Colors.white,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class CheckBtn extends StatelessWidget {
  bool isChecked;
  VoidCallback? onCheck;
  CheckBtn({super.key, required this.isChecked, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isChecked ? onCheck : null,
      child: Container(
        padding: const EdgeInsets.all(3.0),
        height: 60,
        width: 200,
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

