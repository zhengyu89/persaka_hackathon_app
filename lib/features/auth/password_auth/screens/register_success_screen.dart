import 'dart:async';
import 'package:flutter/material.dart';

class RegisterSuccessScreen extends StatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  State<RegisterSuccessScreen> createState() =>
      _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<RegisterSuccessScreen> {
  Timer? _timer; // ✅ store timer

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return; // ✅ prevent crash
      Navigator.pushReplacementNamed(context, '/verify');
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black12,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Registration Successful!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Check your email for a verification link",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Redirecting to verification...",
                      style: TextStyle(color: Color(0xFF3D0075)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
