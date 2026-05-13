import 'package:flutter/material.dart';

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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF4F39F6),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: items
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
