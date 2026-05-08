import 'package:flutter/material.dart';
import '../../board/screens/board_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../submit/screens/submit_screen.dart';
import '../../team/screens/team_screen.dart';
import '../../profile/screens/profile_screen.dart';

class JudgeDashboard extends StatefulWidget {
  const JudgeDashboard({super.key});

  @override
  State<JudgeDashboard> createState() => _JudgeDashboardState();
}

class _JudgeDashboardState extends State<JudgeDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // const HomeScreen(),
    // const TeamScreen(),
    // const SubmitScreen(),
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        selectedItemColor: const Color(0xFF4F39F6),
        unselectedItemColor: const Color(0xFF6B7280),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          // BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          // BottomNavigationBarItem(icon: Icon(Icons.group), label: "Team"),
          // BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Submit"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: "Board"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
