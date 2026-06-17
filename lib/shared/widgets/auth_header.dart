import 'package:flutter/material.dart';

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
          gradient: LinearGradient(
            colors: [
              Color(0xFF4F39F6),
              Color(0xFF9810FA),
              Color(0xFF432DD7),
            ],
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
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

            Image.asset(
            'assets/images/hackathon.png',
            width: 150,
            height: 150,
          ),

            const SizedBox(height: 20),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
