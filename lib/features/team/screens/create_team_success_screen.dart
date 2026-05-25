import 'dart:async';

import 'package:flutter/material.dart';

class CreateTeamSuccessScreen extends StatefulWidget {
  const CreateTeamSuccessScreen({
    super.key,
    required this.teamName,
    required this.teamCode,
  });

  final String teamName;
  final String teamCode;

  @override
  State<CreateTeamSuccessScreen> createState() =>
      _CreateTeamSuccessScreenState();
}

class _CreateTeamSuccessScreenState
    extends State<CreateTeamSuccessScreen> {
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
      backgroundColor: const Color(0xFFF9FAFB),
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
                  Color(0xFF4F39F6),
                  Color(0xFF9810FA),
                  Color(0xFF432DD7),
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
                  'Success!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your team is ready to go',
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
                              Color(0xFF9810FA),
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
                    'Team Created!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.teamName,
                          style: const TextStyle(
                            color: Color(0xFF4F39F6),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text:
                              ' has been added to your team workspace.',
                          style: TextStyle(
                            color: Color(0xFF4A5565),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFC6D2FF),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Team Code',
                          style: TextStyle(
                            color: Color(0xFF4A5565),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF615FFF),
                                Color(0xFF9810FA),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              widget.teamCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Share this code with your team members.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6A7282),
                            fontSize: 13,
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
                          color: Color(0xFF4F39F6),
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
