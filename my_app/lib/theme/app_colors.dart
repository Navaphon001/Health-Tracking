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
  static const Color primaryBackground = Color.fromARGB(139, 10, 186, 180);
  static const Color greyBackground = Color(0xFF919191);
  
  // ===== Additional Text Colors =====
  static const Color textDark = Color(0xFF333333);

  // ===== Dark mode =====
  static const Color darkIvory = Color(0xFFFFFCFB); // FFFFCFB

  // Chart Colors
  static const Color chartPrimary = Color(0xFF0ABAB5);
  static const Color chartSecondary = Color(0xFF56DFCF);
  static const Color chartAccent = Color(0xFF7FDBDA);
  static const Color chartGrey = Color(0xFFE5E7EB);

  // Tag Colors for Beverages
  static const List<Color> tagColors = [
    Color(0xFF0ABAB5), // Teal (Primary)
    Color(0xFF56DFCF), // Light Teal
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Cyan
    Color(0xFFFFE66D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFF38BA8), // Pink
    Color(0xFFA8E6CF), // Light Green
    Color(0xFFFFD93D), // Golden Yellow
    Color(0xFF6BCF7F), // Green
    Color(0xFF4D96FF), // Blue
    Color(0xFFFFB347), // Orange
  ];
}