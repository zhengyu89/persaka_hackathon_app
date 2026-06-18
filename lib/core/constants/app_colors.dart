import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - accents only
  static const Color persakaRed = Color(0xFFFF001F); // #FF001F (2%)
  static const Color darkPurple = Color(0xFF4B0082); // #4B0082 (8%)
  static const Color accentPurple = Color(0xFF6A0DAD);

  // Background / surface palette (mostly white & light grey)
  static const Color lightGray = Color(0xFFF5F5F5); // #F5F5F5
  static const Color darkGray = Color(0xFF666666);
  static const Color midnight = Color(0xFFFFFFFF);
  static const Color navy = Color(0xFFF5F7FA);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color glassPanel = Color(0xFFFFFFFF);
  static const Color mutedText = Color(0xFF666666);
  static const Color subtleText = Color(0xFF7A7A7A);

  static const Color primary = persakaRed;
  static const Color secondary = darkPurple;
  static const Color accent = accentPurple;

  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      primary,
      accentPurple,
      secondary,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [
      Color(0xFFFF0A1F),
      Color(0xFFE00018),
      Color(0xFFB80044),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color backgroundDark = lightGray;
  static const Color backgroundLight = Color(0xFFF8F8FB);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = mutedText;
  static const Color textDark = Color(0xFF1A1A1A);

  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFFF0A1F);
  static const Color warning = Color(0xFFF59E0B);

  static Color glassWhite = Colors.white;
  static Color glassBorder = Colors.black.withOpacity(0.08);
  static Color softShadow = Colors.black.withOpacity(0.08);
  static Color purpleTint = darkPurple.withOpacity(0.08);
  static Color redTint = persakaRed.withOpacity(0.08);
}
