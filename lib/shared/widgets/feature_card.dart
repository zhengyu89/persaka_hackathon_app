import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;

  const FeatureCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel.withOpacity(0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              )),
          Text(description,
              style: const TextStyle(color: AppColors.mutedText)),
        ],
      ),
    );
  }
}
