import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'email_link_auth_service.dart';

class EmailLinkHandler {
  EmailLinkHandler({EmailLinkAuthService? authService})
    : _authService = authService ?? EmailLinkAuthService();

  final EmailLinkAuthService _authService;

  // Call this from app start, app resume, or any deep-link entry point that
  // already has the incoming link string available.
  Future<EmailLinkHandlingResult> handleIncomingLink(String? link) async {
    final String normalizedLink = link?.trim() ?? '';

    if (normalizedLink.isEmpty) {
      return const EmailLinkHandlingResult.ignored();
    }

    if (!_authService.isEmailSignInLink(normalizedLink)) {
      return const EmailLinkHandlingResult.ignored();
    }

    try {
      final UserCredential? userCredential = await _authService
          .completeEmailLinkSignIn(normalizedLink);
      return EmailLinkHandlingResult.success(userCredential);
    } on EmailLinkAuthException catch (error) {
      return EmailLinkHandlingResult.failure(error.message);
    } catch (error, stackTrace) {
      debugPrint('Email link handler failed: $error\n$stackTrace');
      return const EmailLinkHandlingResult.failure(
        'Unable to complete sign-in right now.',
      );
    }
  }
}

class EmailLinkHandlingResult {
  const EmailLinkHandlingResult._({
    required this.handled,
    required this.isSuccess,
    this.userCredential,
    this.errorMessage,
  });

  const EmailLinkHandlingResult.ignored()
    : this._(handled: false, isSuccess: false);

  EmailLinkHandlingResult.success(UserCredential? userCredential)
    : this._(handled: true, isSuccess: true, userCredential: userCredential);

  const EmailLinkHandlingResult.failure(String message)
    : this._(handled: true, isSuccess: false, errorMessage: message);

  final bool handled;
  final bool isSuccess;
  final UserCredential? userCredential;
  final String? errorMessage;
}
