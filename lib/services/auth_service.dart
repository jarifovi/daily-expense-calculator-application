import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user auth state stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user object
  User? get currentUser => _auth.currentUser;

  // Register user
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login user
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
