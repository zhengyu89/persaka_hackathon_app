import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'email_link_storage.dart';

class EmailLinkAuthService {
  EmailLinkAuthService({FirebaseAuth? auth, EmailLinkStorage? storage})
    : _auth = auth ?? FirebaseAuth.instance,
      _storage = storage ?? EmailLinkStorage();

  final FirebaseAuth _auth;
  final EmailLinkStorage _storage;

  bool isEmailSignInLink(String link) {
    return link.trim().isNotEmpty && _auth.isSignInWithEmailLink(link.trim());
  }

  Future<void> sendEmailLink(String email) async {
    final String normalizedEmail = email.trim();

    try {
      await _storage.saveEmail(normalizedEmail);
      await _auth.sendSignInLinkToEmail(
        email: normalizedEmail,
        actionCodeSettings: EmailLinkActionCodeSettings.build(),
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint(
        'Send email-link sign-in failed (${error.code}): ${error.message}\n$stackTrace',
      );
      await _storage.clearEmail();
      throw EmailLinkAuthException(_mapSendLinkMessage(error.code));
    } catch (error, stackTrace) {
      debugPrint('Send email-link sign-in failed: $error\n$stackTrace');
      await _storage.clearEmail();
      throw const EmailLinkAuthException(
        'Unable to send the sign-in link right now.',
      );
    }
  }

  Future<UserCredential?> completeEmailLinkSignIn(String link) async {
    final String normalizedLink = link.trim();

    if (!isEmailSignInLink(normalizedLink)) {
      throw const EmailLinkAuthException(
        'This sign-in link is invalid or has expired.',
      );
    }

    final String? savedEmail = await _storage.loadEmail();
    if (savedEmail == null) {
      throw const EmailLinkAuthException(
        'We could not find the saved email for this link. Please request a new sign-in link on this device.',
      );
    }

    try {
      final UserCredential credential = await _auth.signInWithEmailLink(
        email: savedEmail,
        emailLink: normalizedLink,
      );
      await _storage.clearEmail();
      return credential;
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint(
        'Complete email-link sign-in failed (${error.code}): ${error.message}\n$stackTrace',
      );
      throw EmailLinkAuthException(_mapCompleteLinkMessage(error.code));
    } catch (error, stackTrace) {
      debugPrint('Complete email-link sign-in failed: $error\n$stackTrace');
      throw const EmailLinkAuthException(
        'Unable to complete sign-in right now.',
      );
    }
  }

  String _mapSendLinkMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts right now. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return 'Unable to send the sign-in link right now.';
    }
  }

  String _mapCompleteLinkMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-action-code':
      case 'expired-action-code':
        return 'This sign-in link is invalid or has expired.';
      case 'user-disabled':
        return 'This account is disabled.';
      case 'too-many-requests':
        return 'Too many attempts right now. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return 'Unable to complete sign-in right now.';
    }
  }
}

class EmailLinkActionCodeSettings {
  const EmailLinkActionCodeSettings._();

  // Keep all Firebase email-link settings here so existing auth flows can
  // plug this in without chasing values through multiple files.
  static const String continueUrl = 'https://example.com/email-link-sign-in';
  static const String androidPackageName = 'com.example.persaka_hackathon_app';
  static const bool androidInstallApp = true;
  static const String androidMinimumVersion = '1';
  static const String iOSBundleId = 'com.example.persakaHackathonApp';
  static const String? linkDomain = null;

  static ActionCodeSettings build() {
    return ActionCodeSettings(
      url: continueUrl,
      handleCodeInApp: true,
      androidPackageName: androidPackageName,
      androidInstallApp: androidInstallApp,
      androidMinimumVersion: androidMinimumVersion,
      iOSBundleId: iOSBundleId,
      linkDomain: linkDomain,
    );
  }
}

class EmailLinkAuthException implements Exception {
  const EmailLinkAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
