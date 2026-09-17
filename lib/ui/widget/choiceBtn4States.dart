import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

class ChoiceBtnStates extends StatelessWidget {
  ChoiceBtnStates({
    super.key,
    required this.value,
    required this.state,
    required this.onChoose,
  });

  final String value;
  final ButtonState state;
  final VoidCallback onChoose;
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppTheme.darkBase;
    Color textColor = Colors.white;
    Color borderColor = AppTheme.darkCard;

    switch (state) {
      case ButtonState.selected:
        backgroundColor = AppTheme.darkSurface;
        borderColor = AppTheme.BlueMuted;
        textColor = AppTheme.BlueMuted;
        break;
      case ButtonState.done:
        backgroundColor = AppTheme.darkBase;
        borderColor = AppTheme.darkCard;
        textColor = AppTheme.darkerCard;
        break;
      case ButtonState.normal:
        backgroundColor = AppTheme.darkBase;
        borderColor = AppTheme.darkCard;
        textColor = Colors.white;
        break;
      case ButtonState.wrong:
        backgroundColor = AppTheme.darkSurface;
        borderColor = AppTheme.redMuted;
        textColor = AppTheme.redMuted;
        break;
    }
    return GestureDetector(
      onTap: () {
        if (state != ButtonState.done) {
          onChoose.call();
        }
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: BoxBorder.all(color: borderColor, width: 4),
          color: backgroundColor,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 27,
              fontWeight: FontWeight.bold,

            ),
          ),
        ),
      ),
    );
  }
}

