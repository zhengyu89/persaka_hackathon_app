import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../routes/app_routes.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  int countdown = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    countdown = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown == 0) {
        t.cancel();
      } else {
        setState(() => countdown--);
      }
    });
  }

  Future<void> resendEmail() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    startTimer();
  }

  Future<void> checkVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      if (!mounted) {
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not verified yet')),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4F39F6),
                    Color(0xFF9810FA),
                    Color(0xFF432DD7),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.mark_email_read, size: 60, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Almost there!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Check Your Inbox',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "We've sent a verification link to:",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFF4F39F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Click the link in the email to verify your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F39F6),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: checkVerification,
                      child: const Text("I've Verified My Email"),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: countdown == 0 ? resendEmail : null,
                      child: Text(
                        countdown == 0
                            ? 'Resend Email'
                            : 'Resend in ${countdown}s',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Can't find the email?"),
                          SizedBox(height: 6),
                          Text('Check spam folder'),
                          Text('Check your email address'),
                          Text('Wait a few minutes'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
