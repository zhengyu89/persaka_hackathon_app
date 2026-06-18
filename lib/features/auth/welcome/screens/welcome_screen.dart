import 'package:flutter/material.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/feature_card.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 🚀 Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Text("🚀", style: TextStyle(fontSize: 40)),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Hackathon OS",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "The all-in-one platform for university hackathons",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 30),

                // FEATURES
                const FeatureCard(
                  title: "Team Formation",
                  description: "Find teammates easily",
                ),
                const SizedBox(height: 10),
                const FeatureCard(
                  title: "Live Judging",
                  description: "Real-time scoring",
                ),
                const SizedBox(height: 10),
                const FeatureCard(
                  title: "One Platform",
                  description: "Replace Forms & WhatsApp",
                ),

                const Spacer(),

                // BUTTONS
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF3D0075),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text("Get Started"),
                ),

                const SizedBox(height: 10),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text("I Already Have an Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
