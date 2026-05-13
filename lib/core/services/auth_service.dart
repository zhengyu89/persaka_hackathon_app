import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  // =========================
  // 🔐 EMAIL AUTH
  // =========================

  Future<User?> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await _ensureUserDocument(
        user,
        fallbackEmail: email.trim(),
      );
    }

    return user;
  }

  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;

    if (user != null) {
      await _ensureUserDocument(
        user,
        fallbackEmail: email.trim(),
      );
    }

    return user;
  }

  Future<String> getUserRole(User user) async {
    if (_isAdminEmail(user.email)) {
      return 'admin';
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return doc.data()?['role'] ?? 'participant';
    }

    return 'participant';
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // =========================
  // 🌐 GOOGLE SIGN-IN
  // =========================

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _ensureUserDocument(user);
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw GoogleSignInAuthException(_mapFirebaseGoogleMessage(error.code));
    } on PlatformException catch (error) {
      throw GoogleSignInAuthException(_mapPlatformGoogleMessage(error));
    } catch (_) {
      throw const GoogleSignInAuthException(
        'Google sign-in could not be completed right now.',
      );
    }
  }

  String _mapFirebaseGoogleMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email using a different sign-in method.';
      case 'invalid-credential':
        return 'The Google sign-in credential is invalid or expired.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled in Firebase Authentication yet.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Check your internet connection and try Google sign-in again.';
      default:
        return 'Google sign-in could not be completed right now.';
    }
  }

  String _mapPlatformGoogleMessage(PlatformException error) {
    final String code = error.code.toLowerCase();
    final String message = (error.message ?? '').toLowerCase();
    if (code.contains('network') || message.contains('network')) {
      return 'Check your internet connection and try Google sign-in again.';
    }
    if (code.contains('sign_in_canceled') || code.contains('canceled')) {
      return 'Google sign-in was cancelled.';
    }
    if (message.contains('apiexception: 10') ||
        message.contains('developer error') ||
        code.contains('sign_in_failed')) {
      return 'Google sign-in is not configured for this Android build yet.';
    }
    return 'Google sign-in could not be completed right now.';
  }

  // =========================
  // 📡 AUTH STATE
  // =========================

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // =========================
  // 👤 PROFILE UPDATE
  // =========================

  Future<void> updateProfile({
    required String displayName,
    required String phoneNumber,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(displayName);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({
          'name': displayName,
          'phoneNumber': phoneNumber,
          'email': user.email,
          if (photoURL != null) 'photoURL': photoURL,
        }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  Future<void> _ensureUserDocument(
    User user, {
    String? fallbackEmail,
  }) async {
    final normalizedEmail = (user.email ?? fallbackEmail ?? '').trim();
    final role = _isAdminEmail(normalizedEmail) ? 'admin' : 'participant';
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'email': normalizedEmail,
        'name': user.displayName ?? '',
        'role': role,
      });
      return;
    }

    if (role == 'admin' && doc.data()?['role'] != 'admin') {
      await docRef.set({
        'email': normalizedEmail,
        'name': doc.data()?['name'] ?? user.displayName ?? '',
        'role': 'admin',
      }, SetOptions(merge: true));
    }
  }

  bool _isAdminEmail(String? email) {
    const adminEmails = [
      'danishekhsan@gmail.com', // Aiman (testing for admin role)
      'admin2@gmail.com',
      'admin3@gmail.com',
      'h58176801@gmail.com', // Aidil
      'tanzhengyutan@gmail.com', // Tan Zheng Yu
    ];

    return adminEmails.contains(email?.trim());
  }
}

class GoogleSignInAuthException implements Exception {
  const GoogleSignInAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
