import 'package:flutter/material.dart';
import '../auth_wrapper.dart';
import '../features/auth/password_auth/screens/login_screen.dart';
import '../features/auth/password_auth/screens/register_screen.dart';
import '../features/auth/email_verification/screens/email_verification_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const verify = '/verify';
  static const home = '/home';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    verify: (_) => const EmailVerificationScreen(),
    home: (_) => const AuthWrapper(),
  };
}
