import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 🏆 Title (e.g. Hackathon OS)
  static const TextStyle title = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // 🔤 Subtitle
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  // 🧾 Body
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  // 🔘 Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // ❗ Error
  static const TextStyle error = TextStyle(
    fontSize: 13,
    color: AppColors.error,
  );

  // ✅ Success
  static const TextStyle success = TextStyle(
    fontSize: 13,
    color: AppColors.success,
  );
}