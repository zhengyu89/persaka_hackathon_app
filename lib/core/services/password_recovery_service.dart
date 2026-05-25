import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PasswordRecoveryService {
  PasswordRecoveryService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<void> sendPasswordReset(String email) async {
    final String normalizedEmail = email.trim();

    try {
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint(
        'Password reset failed (${error.code}): ${error.message}\n$stackTrace',
      );
      throw PasswordRecoveryException(_mapFirebaseMessage(error.code));
    } catch (error, stackTrace) {
      debugPrint('Password reset failed: $error\n$stackTrace');
      throw const PasswordRecoveryException(
        'Unable to send the reset email right now.',
      );
    }
  }

  String _mapFirebaseMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts right now. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return 'Unable to send the reset email right now.';
    }
  }
}

class PasswordRecoveryException implements Exception {
  const PasswordRecoveryException(this.message);

  final String message;

  @override
  String toString() => message;
}
