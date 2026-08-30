import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/app_theme.dart';
import 'package:totoki_extract/business/user/lessonType.dart';

class AnalyzeSpacing {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AnalyzeColors {
  // Lesson type colors
  static Color lessonColor(LessonType t) => switch(t) {
    LessonType.dailyLearn => AppTheme.primaryTeal,
    LessonType.ielts => AppTheme.bluePrimary,
  };

  static Color lessonColorFromIndex(int index) => switch(index) {
    0 => AppTheme.primaryTeal,
    1 => AppTheme.bluePrimary,
    _ => AppTheme.primaryTeal,
  };

  // Light theme colors
  static const Color bgPrimary = Colors.white;
  static const Color bgSecondary = Color(0xFFFAFAFA); // grey[50]
  static const Color bgCard = Colors.white;
  static const Color borderLight = Color(0xFFE0E0E0); // grey[300]
  static const Color borderMedium = Color(0xFFBDBDBD); // grey[400]
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textMuted = Colors.black38;
  static const Color dividerColor = Color(0xFFF5F5F5); // grey[100]

  // Accent colors (keep from AppTheme)
  static const Color greenPrimary = AppTheme.greenPrimary;
  static const Color bluePrimary = AppTheme.bluePrimary;
  static const Color redPrimary = AppTheme.redPrimary;
  static const Color yellowPrimary = AppTheme.yellowPrimary;
  static const Color pinkPrimary = AppTheme.pinkPrimary;
  static const Color primaryTeal = AppTheme.primaryTeal;
}