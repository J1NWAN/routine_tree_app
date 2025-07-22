import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromRGBO(61, 65, 75, 1);
  static const Color success = Color(0xFF4CAF50);
  static const Color background = Color.fromRGBO(235, 235, 235, 1.0);
  static const Color error = Colors.red;
  static const Color white = Colors.white;
  static const Color black87 = Colors.black87;
  
  // Opacity colors helper methods (deprecated withOpacity 대신 사용)
  static Color greyWithAlpha(double alpha) => Colors.grey.withAlpha((255 * alpha).toInt());
  static Color primaryWithAlpha(double alpha) => primary.withAlpha((255 * alpha).toInt());
  static Color blueWithAlpha(double alpha) => Colors.blue.withAlpha((255 * alpha).toInt());
}