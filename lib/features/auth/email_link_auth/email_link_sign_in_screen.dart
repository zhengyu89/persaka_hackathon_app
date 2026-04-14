import 'package:flutter/material.dart';

import '../shared/auth_ui.dart';
import 'email_link_auth_service.dart';

class EmailLinkSignInScreen extends StatefulWidget {
  const EmailLinkSignInScreen({super.key, EmailLinkAuthService? service})
    : _service = service;

  final EmailLinkAuthService? _service;

  @override
  State<EmailLinkSignInScreen> createState() => _EmailLinkSignInScreenState();
}

class _EmailLinkSignInScreenState extends State<EmailLinkSignInScreen> {
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  late final EmailLinkAuthService _service =
      widget._service ?? EmailLinkAuthService();
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
      await _service.sendEmailLink(email);
      if (!mounted) {
        return;
      }
      setState(() {
        _successMessage =
            'Check your email for the sign-in link and open it on this device.';
        _errorMessage = null;
      });
    } on EmailLinkAuthException catch (error) {
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
      title: 'Email Link Sign-In',
      subtitle: 'Send a secure sign-in link without using a password.',
      cardTitle: 'Sign in from your email',
      cardDescription:
          'We save this email on the current device so the incoming link can finish sign-in here.',
      footer: const Text(
        'This feature intentionally stays separate from the existing password-based login flow.',
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
          label: 'Send sign-in link',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
