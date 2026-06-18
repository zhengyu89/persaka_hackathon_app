import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundLight,
            AppColors.lightGray,
            AppColors.panel,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -72,
            top: -56,
            child: _PatternRing(color: AppColors.persakaRed.withOpacity(0.16)),
          ),
          Positioned(
            left: -92,
            bottom: -82,
            child: _PatternRing(
              color: AppColors.accentPurple.withOpacity(0.18),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 120,
            child: _CircuitDots(color: AppColors.darkPurple.withOpacity(0.05)),
          ),
          child,
        ],
      ),
    );
  }
}

class _CircuitDots extends StatelessWidget {
  const _CircuitDots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: List.generate(
          25,
          (_) => Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _PatternRing extends StatelessWidget {
  const _PatternRing({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 28),
      ),
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
            Color(0xFFFF0A1F),
            Color(0xFF5A189A),
            Color(0xFFE60076),
          ],
        ),
      ),
      child: child,
    );
  }
} */

