import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/services/auth_service.dart';

import 'features/auth/email_verification/screens/email_verification_screen.dart';
import 'features/auth/password_auth/screens/login_screen.dart';

import 'features/admin/screens/admin_dashboard.dart';
import 'features/judge/screens/judge_dashboard.dart';
import 'features/participant/screens/participant_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          // Not logged in
          if (user == null) {
            return const LoginScreen();
          }

          // Email not verified
          if (!user.emailVerified) {
            return const EmailVerificationScreen();
          }

          // Logged in + verified
          return FutureBuilder<String>(
            future: AuthService().getUserRole(user),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final role = roleSnapshot.data ?? 'participant';

              // ROLE-BASED DASHBOARD
              if (role == 'admin') {
                return const AdminDashboard();
              }

              if (role == 'judge') {
                return const JudgeDashboard();
              }

              return const ParticipantDashboard();
            },
          );
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}