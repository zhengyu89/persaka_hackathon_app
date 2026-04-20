import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFF), // ✅ match original UI
      child: child,
    );
  }
}

/* class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4F39F6),
            Color(0xFF9810FA),
            Color(0xFFE60076),
          ],
        ),
      ),
      child: child,
    );
  }
} */

