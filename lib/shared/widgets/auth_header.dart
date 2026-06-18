import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final bool showBack;
  final VoidCallback? onBackTap;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    this.showBack = false,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBackTap ?? () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8, right: 16),
                    child: Text(
                      'Back to Login',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),

            if (showBack) const SizedBox(height: 20),

            Container(
              width: 144,
              height: 144,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Image.asset('assets/images/hackathon.png'),
            ),

            const SizedBox(height: 20),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
