import 'package:flutter/material.dart';

class AppColors {
  // 🌈 Primary Gradient (from your Figma)
  static const Color primary = Color(0xFF4F39F6);
  static const Color secondary = Color(0xFF9810FA);
  static const Color accent = Color(0xFFE60076);

  // 🎨 Gradient
  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      primary,
      secondary,
      accent,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🖤 Background
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundLight = Colors.white;

  // ⚪ Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE0E7FF);
  static const Color textDark = Colors.black;

  // 🟢 Status Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;

  // 🧊 Glass Effect
  static Color glassWhite = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);
}