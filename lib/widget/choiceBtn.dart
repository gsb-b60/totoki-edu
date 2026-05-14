import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';

class ChoiceBtn extends StatelessWidget {
  String value;
  bool isSelected;
  VoidCallback? onPressed;
  ChoiceBtn({
    super.key,
    required this.isSelected,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 175,
        height: 70,
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
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}

