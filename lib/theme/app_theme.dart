
import 'package:flutter/material.dart';


class AppTheme{
  static const Color primaryTeal = Colors.teal;
  static const Color primaryRed = Colors.red;
  static const Color blueist = Color.fromARGB(255, 77, 138, 187);
  static const Color lightText = Colors.white;
  static const Color darkText = Colors.black;

  static const Color accentTeal = Color.fromARGB(255, 10, 114, 104);

  static const darkBase = Color(0xFF000000);
  static const darkSurface = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkBorder = Color(0xFF2C2C2C);
  static const darkerCard = Color(0xFF161616);
  static const darklight = Color(0xFF2A2A2A);
  static const greyGreen = Color.fromRGBO(129, 188, 126, 1);

  static const greenPrimary = Color.fromRGBO(149, 211, 50, 1);
  static const greenAccent = Color.fromRGBO(121, 186, 4, 1);
  static const greenMuted = Color.fromRGBO(96, 132, 34, 1);
  static const greenBright = Color.fromRGBO(120, 186, 49, 1);
  static const greenDeep = Color.fromRGBO(1, 125, 3, 1);
  static const greenFade = Color.fromRGBO(136, 255, 89, 1);

  static const redPrimary = Color.fromRGBO(199, 73, 73, 1);
  static const redAccent = Color.fromRGBO(217, 81, 76, 1);
  static const redBright = Color.fromRGBO(239, 87, 82, 1);
  static const redMuted = Color.fromRGBO(216, 69, 75, 1);

  static const BlueMuted = Color.fromRGBO(57, 131, 158, 1);
  static const blueLight = Color.fromRGBO(69, 192, 249, 1);
  static const bluePrimary = Color.fromRGBO(33, 152, 215, 1);

  static const yellowPrimary = Color.fromRGBO(255, 201, 4, 1);
  static const yellowAccent = Color.fromARGB(255, 214, 183, 9);
  
  static const bronze = Color(0xFFCD7F32);
  static const silver = Color(0xFFC0C0C0);
  static const amberRank = Color(0xFFFFD700);
  static const platinum = Color(0xFFE5E4E2);
  static const diamond = Color(0xFFB9F2FF);
  static const master = Color(0xFFFF4500); // tùy chọn
  static const challenger = Color(0xFF8A2BE2); // tùy chọn

  static const pinkPrimary = Color.fromRGBO(255, 135, 206, 1);

  static const meanFuse = Color(0xFF4A7C59); // green moss
  static const wordSnap = Color(0xFF3C6E71); // blue-grey teal
  static const mindField = Color(0xFF735D78); // dusty purple

  static const echoSpell = Color(0xFF1C7C54); // deep emerald
  static const echoMatch = Color(0xFF20639B); // deep blue
  static const echoFuse = Color(0xFF6A0572); // purple magenta

  static const neuroPick = Color(0xFF916953); // bronze brown
  static const wordPulse = Color(0xFF6B8E23); // olive green
  static const soundSight = Color(0xFF2E8B57); // sea green

  static const phoneMix = Color(0xFF364958); // dark steel blue

  // --- Typography Scale ---
  static TextStyle heroStyle = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: lightText,
  );

  static TextStyle screenTitleStyle = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: lightText,
  );

  static TextStyle sectionHeaderStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: lightText,
  );

  static TextStyle bodyLargeStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: lightText,
  );

  static TextStyle bodyMediumStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: lightText,
  );

  static TextStyle bodySmallStyle = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: lightText,
  );

  static TextStyle captionStyle = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
    color: lightText,
  );
}

extension FlashcardTheme on AppTheme {
  // Semantic mappings for Flashcard module
  static const Color correct = AppTheme.greenPrimary;
  static const Color wrong = AppTheme.redPrimary;
  static const Color pending = AppTheme.yellowPrimary;
  
  static const Color cardBackground = AppTheme.darkSurface;
  static const Color cardText = AppTheme.lightText;
  
  static Color getStudyModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'meanfuse': return AppTheme.meanFuse;
      case 'wordsnap': return AppTheme.wordSnap;
      case 'mindfield': return AppTheme.mindField;
      case 'echospell': return AppTheme.echoSpell;
      case 'echomatch': return AppTheme.echoMatch;
      case 'echofuse': return AppTheme.echoFuse;
      case 'neuropick': return AppTheme.neuroPick;
      case 'wordpulse': return AppTheme.wordPulse;
      case 'soundsight': return AppTheme.soundSight;
      case 'phonemix': return AppTheme.phoneMix;
      default: return AppTheme.primaryTeal;
    }
  }
}

