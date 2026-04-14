import 'package:flutter/material.dart';

import '../shared/auth_ui.dart';
import 'password_recovery_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, PasswordRecoveryService? service})
    : _service = service;

  final PasswordRecoveryService? _service;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  late final PasswordRecoveryService _service =
      widget._service ?? PasswordRecoveryService();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

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

    setState(() {
      _successMessage = null;
      _errorMessage = validationMessage;
    });

    if (validationMessage != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _service.sendPasswordReset(email);
      if (!mounted) {
        return;
      }
      setState(() {
        _successMessage = 'Password reset email sent. Check your inbox.';
        _errorMessage = null;
      });
    } on PasswordRecoveryException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _successMessage = null;
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
      return 'Email is required.';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthFeatureScaffold(
      title: 'Forgot Password',
      subtitle: 'Request a reset link to get back into your account.',
      cardTitle: 'Reset your password',
      cardDescription:
          'Enter the same email address you use to sign in and we will send a password reset link.',
      footer: const Text(
        'This screen only handles password reset. Registration, password login, and email verification stay in the existing auth flow.',
        style: TextStyle(
          color: Color(0xFF6A7282),
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
      children: [
        AuthTextField(
          controller: _emailController,
          label: 'Email address',
          hintText: 'name@example.com',
          enabled: !_isLoading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => _submit(),
        ),
        if (_successMessage != null) ...[
          const SizedBox(height: 16),
          AuthStatusMessage.success(_successMessage!),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          AuthStatusMessage.error(_errorMessage!),
        ],
        const SizedBox(height: 24),
        AuthPrimaryButton(
          label: 'Send reset email',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
