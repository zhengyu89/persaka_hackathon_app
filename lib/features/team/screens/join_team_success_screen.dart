import 'dart:async';

import 'package:flutter/material.dart';

class JoinTeamSuccessScreen extends StatefulWidget {
  const JoinTeamSuccessScreen({
    super.key,
    required this.teamName,
    required this.teamCode,
  });

  final String teamName;
  final String teamCode;

  @override
  State<JoinTeamSuccessScreen> createState() =>
      _JoinTeamSuccessScreenState();
}

class _JoinTeamSuccessScreenState
    extends State<JoinTeamSuccessScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    _redirectTimer = Timer(
      const Duration(seconds: 3),
      _goBackToTeams,
    );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _goBackToTeams() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 70,
              left: 20,
              right: 20,
              bottom: 50,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF0A1F),
                  Color(0xFF5A189A),
                  Color(0xFF3D0075),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      '🎉',
                      style: TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You are part of the team now',
                  style: TextStyle(
                    color: Color(0xFFD6D6FF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE0E7FF),
                          Color(0xFFF3E8FF),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF615FFF),
                              Color(0xFF5A189A),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Successfully Joined!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You are now a member of ${widget.teamName}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4A5565),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE9D4FF),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.celebration_rounded,
                              color: Color(0xFF5A189A),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Welcome to your new team!',
                              style: TextStyle(
                                color: Color(0xFF364153),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              widget.teamCode,
                              style: const TextStyle(
                                color: Color(0xFFFF0A1F),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Returning to your team workspace...',
                        style: TextStyle(
                          color: Color(0xFFFF0A1F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _goBackToTeams,
                    child: const Text('Go now'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
