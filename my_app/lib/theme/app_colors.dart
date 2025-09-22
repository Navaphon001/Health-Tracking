import 'package:flutter/material.dart';

/// Centralized brand colors
class AppColors {
  // ===== Primary Colors =====
  static const Color primary = Color(0xFF0ABAB5);
  static const Color primaryLight = Color(0xFF0ABAB5); // FF0ABAB5
  static const Color gradientLightEnd = Color(0xFF56DFCF); // FF56DFCF

  // ===== Text Colors =====
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Colors.grey;

  // ===== Background Colors =====
  // fromARGB(A, R, G, B)
  static const Color primaryBackground = Color.fromARGB(139, 10, 186, 186);
  static const Color greyBackground = Color(0xFF919191);

  // ===== Additional Text Colors =====
  static const Color textDark = Color(0xFF333333);

  // ===== Dark mode =====
  static const Color darkIvory = Color(0xFFFFFCFB);

  // ===== Optional: Gradient helper =====
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, gradientLightEnd],
  );
}
