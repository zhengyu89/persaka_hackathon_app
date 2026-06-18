import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class GlobalBottomNavItem {
  const GlobalBottomNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

const List<GlobalBottomNavItem> adminBottomNavItems = [
  GlobalBottomNavItem(
    icon: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
  GlobalBottomNavItem(
    icon: Icons.groups_rounded,
    label: 'Teams',
  ),
  GlobalBottomNavItem(
    icon: Icons.rocket_launch_rounded,
    label: 'Hackathons',
  ),
  GlobalBottomNavItem(
    icon: Icons.emoji_events_outlined,
    label: 'Board',
  ),
  GlobalBottomNavItem(
    icon: Icons.person_outline_rounded,
    label: 'Profile',
  ),
];

class GlobalBottomNavBar extends StatelessWidget {
  const GlobalBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlobalBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
            bottom: Radius.circular(20),
          ),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow,
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
            bottom: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.panel,
            elevation: 0,
            selectedItemColor: AppColors.darkPurple,
            unselectedItemColor: AppColors.darkGray,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
            ),
            items: List.generate(items.length, (index) {
              final item = items[index];

              return BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: index == currentIndex
                        ? AppColors.purpleTint
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(item.icon, size: 23),
                ),
                label: item.label,
              );
            }),
          ),
        ),
      ),
    );
  }
}
