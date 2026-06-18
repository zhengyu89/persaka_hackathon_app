import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PersakaAppShell extends StatelessWidget {
  const PersakaAppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const Positioned(
          left: 12,
          right: 12,
          bottom: 4,
          child: IgnorePointer(child: _PersakaFooter()),
        ),
      ],
    );
  }
}

class _PersakaFooter extends StatelessWidget {
  const _PersakaFooter();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.midnight.withOpacity(0.62),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: AppColors.persakaRed.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.subtleText,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
