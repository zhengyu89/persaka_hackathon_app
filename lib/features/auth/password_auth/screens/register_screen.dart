import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/email_verification_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/google_sign_in_button.dart'; // ✅ NEW

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final auth = AuthService();
  final verify = EmailVerificationService();

  String error = '';
  bool isLoading = false;
  bool isGoogleLoading = false;

  Future<void> register() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => error = 'Please fill in all fields');
      return;
    }

    if (!emailController.text.contains('@')) {
      setState(() => error = 'Please enter a valid email');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() => error = 'Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final user = await auth.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        await verify.sendEmail();

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, AppRoutes.verify);
      }
    } catch (e) {
      if (!mounted) return;

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            error = 'This email is already registered';
            break;
          case 'weak-password':
            error = 'Password is too weak';
            break;
          case 'invalid-email':
            error = 'Invalid email format';
            break;
          default:
            error = 'Registration failed';
        }
      } else {
        error = 'Something went wrong';
      }

      setState(() {});
    }

    if (!mounted) return;

    setState(() => isLoading = false);
  }

  Future<void> registerWithGoogle() async {
    if (isGoogleLoading) {
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      isGoogleLoading = true;
      error = '';
    });

    try {
      final user = await auth.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        navigator.pushReplacementNamed(AppRoutes.home);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled')),
        );
      }
    } on GoogleSignInAuthException catch (googleError) {
      if (!mounted) return;
      setState(() => error = googleError.message);
    } finally {
      if (mounted) {
        setState(() => isGoogleLoading = false);
      }
    }
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
            style: TextStyle(color: Color(0xFF6A7282), fontSize: 12),
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
    confirmPasswordController.dispose();
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
                title: 'Register',
                subtitle: 'Create Account',
                description: 'Join the hackathon community',
                showBack: true,
                onBackTap: () => Navigator.pop(context),
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

                      const SizedBox(height: 16),

                      AppInputField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password must contain:',
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'At least 8 characters',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Uppercase and lowercase letters',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'At least one number',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (error.isNotEmpty)
                        Text(error, style: AppTextStyles.error),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: isLoading ? null : register,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            color: AppColors.persakaRed,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      // 🔥 NEW SECTION
                      const SizedBox(height: 20),

                      buildOrDivider(),

                      const SizedBox(height: 20),

                      GoogleSignInButton(
                        onTap: registerWithGoogle,
                        isLoading: isGoogleLoading,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            },
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Text(
                                'Sign in',
                                style: TextStyle(color: Color(0xFF4F39F6)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'By creating an account, you agree to our Terms & Privacy Policy',
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
