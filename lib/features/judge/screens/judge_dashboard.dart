import 'package:flutter/material.dart';
import '../../board/screens/board_screen.dart';
import '../../submit/screens/submissions_review_screen.dart';
import '../../team/screens/team_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../shared/widgets/global_bottom_nav_bar.dart';

class JudgeDashboard extends StatefulWidget {
  const JudgeDashboard({super.key});

  @override
  State<JudgeDashboard> createState() => _JudgeDashboardState();
}

class _JudgeDashboardState extends State<JudgeDashboard> {
  int _currentIndex = 0;

  static const List<GlobalBottomNavItem> _navItems = [
    GlobalBottomNavItem(icon: Icons.leaderboard, label: 'Board'),
    GlobalBottomNavItem(icon: Icons.group, label: 'Teams'),
    GlobalBottomNavItem(icon: Icons.fact_check_outlined, label: 'Submissions'),
    GlobalBottomNavItem(icon: Icons.person, label: 'Profile'),
  ];

  final List<Widget> _pages = [
    const BoardScreen(),
    const TeamScreen.viewer(
      title: 'Team Directory',
      subtitle:
          'Review registered teams, members, and joined hackathons while judging.',
    ),
    const SubmissionsReviewScreen.judge(),
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
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: GlobalBottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
