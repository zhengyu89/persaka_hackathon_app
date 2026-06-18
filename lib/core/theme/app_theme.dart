import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.persakaRed,
      brightness: Brightness.light,
      primary: AppColors.persakaRed,
      secondary: AppColors.darkPurple,
      tertiary: AppColors.accentPurple,
      surface: AppColors.panel,
      error: AppColors.error,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Inter',
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        elevation: 1,
        shadowColor: Color(0x14000000),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 2,
        margin: EdgeInsets.zero,
        shadowColor: Color(0x18000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.disabled)
                ? const Color(0xFFE5E7EB)
                : AppColors.persakaRed,
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          elevation: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.hovered) ? 8 : 2,
          ),
          shadowColor: MaterialStateProperty.all(
            AppColors.persakaRed.withOpacity(0.28),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPurple,
          side: const BorderSide(color: AppColors.darkPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        prefixIconColor: AppColors.darkPurple,
        hintStyle: const TextStyle(color: AppColors.darkGray),
        labelStyle: const TextStyle(color: AppColors.darkGray),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkPurple, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.accentPurple.withOpacity(0.12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.panel,
        selectedItemColor: AppColors.darkPurple,
        unselectedItemColor: AppColors.darkGray,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    const headingStyle = TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.textDark,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );
    const bodyStyle = TextStyle(
      fontFamily: 'Inter',
      color: AppColors.mutedText,
      letterSpacing: 0,
    );

    return base.copyWith(
      displayLarge: base.displayLarge?.merge(headingStyle),
      displayMedium: base.displayMedium?.merge(headingStyle),
      displaySmall: base.displaySmall?.merge(headingStyle),
      headlineLarge: base.headlineLarge?.merge(headingStyle),
      headlineMedium: base.headlineMedium?.merge(headingStyle),
      headlineSmall: base.headlineSmall?.merge(headingStyle),
      titleLarge: base.titleLarge?.merge(headingStyle),
      titleMedium: base.titleMedium?.merge(headingStyle),
      titleSmall: base.titleSmall?.merge(headingStyle),
      bodyLarge: base.bodyLarge?.merge(bodyStyle),
      bodyMedium: base.bodyMedium?.merge(bodyStyle),
      bodySmall: base.bodySmall?.merge(bodyStyle),
      labelLarge: base.labelLarge?.merge(
        bodyStyle.copyWith(fontWeight: FontWeight.w700),
      ),
      labelMedium: base.labelMedium?.merge(bodyStyle),
      labelSmall: base.labelSmall?.merge(bodyStyle),
    );
  }
}
