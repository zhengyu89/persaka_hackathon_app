import 'package:flutter/material.dart';
import '../auth_wrapper.dart';
import '../features/auth/password_auth/screens/login_screen.dart';
import '../features/auth/password_auth/screens/register_screen.dart';
import '../features/auth/email_verification/screens/email_verification_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/admin/screens/admin_dashboard.dart';
import '../features/judge/screens/judge_dashboard.dart';
import '../features/participant/screens/participant_dashboard.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const verify = '/verify';
  static const home = '/home';
  static const profile = '/profile';
  static const admin = '/admin';
  static const judge = '/judge';
  static const participant = '/participant';
  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    verify: (_) => const EmailVerificationScreen(),
    home: (_) => const AuthWrapper(),
    profile: (_) => const ProfileScreen(),
    admin: (_) => const AdminDashboard(),
    judge: (_) => const JudgeDashboard(),
    participant: (_) => const ParticipantDashboard(),
  };
}
