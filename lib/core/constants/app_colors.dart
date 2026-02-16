import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color primary = Color(0xFF2369FF);
  static const Color secondary = Color(0xFF1F2937);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color textBody = Color(0xFF8B949E);
  static const Color textMain = Colors.white;
  static const Color border = Color(0xFF30363D);

  static Color getTextBody(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return textBody;
    } else {
      return const Color(0xFF4B5563); // Darker grey for light mode
    }
  }
}
