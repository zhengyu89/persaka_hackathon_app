import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/email_verification_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/google_sign_in_button.dart'; // ✅ NEW

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final auth = AuthService();
  final verify = EmailVerificationService();

  String error = '';
  bool isLoading = false;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => error = 'Please fill in all fields');
      return;
    }

    if (!emailController.text.contains('@')) {
      setState(() => error = 'Please enter a valid email');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final user = await auth.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        final isVerified = await verify.isVerified();

        if (!mounted) return;

        if (isVerified) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.verify);
        }
      }
    } catch (e) {
      if (!mounted) return;

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
            error = 'Invalid email or password';
            break;
          case 'invalid-email':
            error = 'Invalid email format';
            break;
          default:
            error = 'Login failed. Please try again';
        }
      } else {
        error = 'Something went wrong';
      }

      setState(() {});
    }

    if (!mounted) return;

    setState(() => isLoading = false);
  }

  // ✅ OR Divider
  Widget buildOrDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: Color(0xFF6A7282),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ],
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AuthHeader(
                title: 'Login',
                subtitle: 'Welcome Back!',
                description: 'Sign in to Hackathon OS',
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black12,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AppInputField(
                        controller: emailController,
                        hintText: 'Email address',
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      AppInputField(
                        controller: passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 10),

                      if (error.isNotEmpty)
                        Text(error, style: AppTextStyles.error),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: isLoading ? null : login,
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4F39F6),
                                Color(0xFF9810FA),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      // 🔥 NEW SECTION (same as Register)
                      const SizedBox(height: 20),

                      buildOrDivider(),

                      const SizedBox(height: 20),

                      GoogleSignInButton(
                        onTap: () async {
                          final user = await auth.signInWithGoogle();

                          if (!mounted) return;

                          if (user != null) {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.home);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Google sign-in cancelled'),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text('Create Account'),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feature coming soon'),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),

                      const SizedBox(height: 10),

                      const Divider(),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feature coming soon'),
                            ),
                          );
                        },
                        child: const Text('Login with Email Link'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Secure authentication for university hackathons',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}