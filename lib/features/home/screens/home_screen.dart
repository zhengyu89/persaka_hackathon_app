import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),

      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(user),
            const SizedBox(height: 16),
            _quickActions(),
            const SizedBox(height: 20),
            _nextEvent(),
            const SizedBox(height: 20),
            _updates(),
            const SizedBox(height: 20),
            _topTeams(),
            const SizedBox(height: 20),
            _stats(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // 🔥 HEADER
  Widget _header(User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4F39F6),
            Color(0xFF9810FA),
            Color(0xFF432DD7),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome back 👋",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          const Text(
            "Spring Hack 2026",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Participant", style: TextStyle(color: Colors.white)),
                Text("Team Alpha (4)",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⚡ QUICK ACTIONS
  Widget _quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
              child:
                  _actionCard("Submit Project", "Upload work", Colors.blue)),
          const SizedBox(width: 10),
          Expanded(
              child:
                  _actionCard("Schedule", "View timeline", Colors.purple)),
        ],
      ),
    );
  }

  Widget _actionCard(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flash_on, color: Colors.white),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _nextEvent() {
    return const _sectionCard(
      title: "Opening Ceremony",
      subtitle: "10:00 AM - 11:00 AM",
      tag: "Live Now",
    );
  }

  Widget _updates() {
    return Column(
      children: const [
        _sectionCard(
          title: "Submission Deadline Extended",
          subtitle: "Now until 6:00 PM",
          tag: "Important",
        ),
        _sectionCard(
          title: "Lunch is Ready!",
          subtitle: "Cafeteria",
          tag: "Info",
        ),
      ],
    );
  }

  Widget _topTeams() {
    return Column(
      children: const [
        ListTile(title: Text("🥇 Code Ninjas"), trailing: Text("95 pts")),
        ListTile(title: Text("🥈 Tech Titans"), trailing: Text("92 pts")),
        ListTile(title: Text("🥉 Innovation Hub"), trailing: Text("88 pts")),
      ],
    );
  }

  Widget _stats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Expanded(child: _statCard("36", "Hours Left")),
          SizedBox(width: 10),
          Expanded(child: _statCard("24", "Teams")),
          SizedBox(width: 10),
          Expanded(child: _statCard("8", "Events")),
        ],
      ),
    );
  }
}

// 🔁 REUSABLE CARD
class _sectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;

  const _sectionCard({
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tag, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// 🔁 STAT CARD
class _statCard extends StatelessWidget {
  final String value;
  final String label;

  const _statCard(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 20)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}