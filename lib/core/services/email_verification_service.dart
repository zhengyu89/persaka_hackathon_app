import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 📧 Send verification email after registration
  Future<void> sendEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// 🔄 Check if user email is verified
  Future<bool> isVerified() async {
    final user = _auth.currentUser;

    // ⚠️ VERY IMPORTANT: reload to get latest status
    await user?.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }

  /// 🔁 Resend verification email
  Future<void> resendEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// 🔍 Get current user email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  /// 🚪 Logout (optional helper)
  Future<void> logout() async {
    await _auth.signOut();
  }
}