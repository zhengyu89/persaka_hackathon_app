import 'package:flutter/material.dart';

import '../../../../core/services/password_recovery_service.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/gradient_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static const LinearGradient _primaryGradient = LinearGradient(
    colors: [Color(0xFFFF0A1F), Color(0xFF5A189A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final TextEditingController _emailController = TextEditingController();
  final PasswordRecoveryService _service = PasswordRecoveryService();

  bool _isLoading = false;
  String _message = '';
  bool _isSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail?.trim() ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    final String email = _emailController.text.trim();
    final String? validationMessage = _validateEmail(email);

    if (validationMessage != null) {
      setState(() {
        _message = validationMessage;
        _isSuccessMessage = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _service.sendPasswordReset(email);

      if (!mounted) {
        return;
      }

      setState(() {
        _message =
            'If an account exists for this email, a password reset link has been sent. Please check your inbox.';
        _isSuccessMessage = true;
      });
    } on PasswordRecoveryException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _message = error.message;
        _isSuccessMessage = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  Widget _buildPrimaryButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: _primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FF0A1F),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child:
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    'Send Reset Link',
                    style: TextStyle(color: Colors.white),
                  ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    if (_message.isEmpty) {
      return const SizedBox.shrink();
    }

    final Color backgroundColor =
        _isSuccessMessage ? const Color(0xFFECFDF3) : const Color(0xFFFEF3F2);
    final Color foregroundColor =
        _isSuccessMessage ? const Color(0xFF027A48) : const Color(0xFFB42318);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _isSuccessMessage
                  ? const Color(0xFFA6F4C5)
                  : const Color(0xFFFDA29B),
        ),
      ),
      child: Text(
        _message,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFF0A1F), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AuthHeader(
                title: 'Forgot Password',
                subtitle: 'Reset your password',
                description: 'We will send a reset link to your email',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF3F0FF),
                              const Color(0xFFF9F5FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: _primaryGradient,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.lock_reset_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reset access securely',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'We will email you a secure password reset link.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'How it works',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF0A1F),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoChip(
                              icon: Icons.alternate_email_rounded,
                              title: 'Enter your account email',
                              description:
                                  'Use the same email address you registered with in the app.',
                            ),
                            _buildInfoChip(
                              icon: Icons.mark_email_read_rounded,
                              title: 'Open the reset email',
                              description:
                                  'Tap the secure reset link sent to your inbox.',
                            ),
                            _buildInfoChip(
                              icon: Icons.password_rounded,
                              title: 'Choose a new password',
                              description:
                                  'Create a fresh password and sign in again.',
                            ),
                            const Text(
                              '1. Enter the email you use for your account.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      AppInputField(
                        controller: _emailController,
                        hintText: 'Email address',
                        icon: Icons.email_outlined,
                      ),

                      if (_message.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildStatusMessage(),
                      ],

                      const SizedBox(height: 20),

                      _buildPrimaryButton(),

                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back to Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'For security, the app does not confirm whether an email address is registered.',
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
