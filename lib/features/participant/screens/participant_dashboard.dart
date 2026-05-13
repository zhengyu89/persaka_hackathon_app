import 'package:flutter/material.dart';
import '../../board/screens/board_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../submit/screens/submit_screen.dart';
import '../../team/screens/team_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../shared/widgets/global_bottom_nav_bar.dart';

class ParticipantDashboard extends StatefulWidget {
  const ParticipantDashboard({super.key});

  @override
  State<ParticipantDashboard> createState() => _ParticipantDashboardState();
}

class _ParticipantDashboardState extends State<ParticipantDashboard> {
  int _currentIndex = 0;

  static const List<GlobalBottomNavItem> _navItems = [
    GlobalBottomNavItem(
      icon: Icons.home,
      label: 'Home',
    ),
    GlobalBottomNavItem(
      icon: Icons.group,
      label: 'Team',
    ),
    GlobalBottomNavItem(
      icon: Icons.upload,
      label: 'Submit',
    ),
    GlobalBottomNavItem(
      icon: Icons.leaderboard,
      label: 'Board',
    ),
    GlobalBottomNavItem(
      icon: Icons.person,
      label: 'Profile',
    ),
  ];

  final List<Widget> _pages = [
    const HomeScreen(),
    const TeamScreen(),
    const SubmitScreen(),
    const BoardScreen(),
    const ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: GlobalBottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
