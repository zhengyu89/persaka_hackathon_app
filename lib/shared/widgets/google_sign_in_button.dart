import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                height: 20,
                errorBuilder:
                    (_, _, _) => const Icon(
                      Icons.account_circle_outlined,
                      size: 20,
                      color: AppColors.subtleText,
                    ),
              ),
            const SizedBox(width: 12),
            Text(
              isLoading ? 'Connecting...' : 'Continue with Google',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
