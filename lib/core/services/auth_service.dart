import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // 🔐 EMAIL AUTH
  // =========================

  Future<User?> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // also sign out google
  }

  // =========================
  // 🌐 GOOGLE SIGN-IN
  // =========================

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _auth.signInWithCredential(credential);

    return userCredential.user;
  }

  // =========================
  // 📡 AUTH STATE
  // =========================

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}