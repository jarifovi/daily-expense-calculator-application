import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  AuthProvider() {
    // Listen to authentication state changes automatically on initialization
    _authService.userStream.listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Clear errors
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Sign In
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmailAndPassword(email.trim(), password);
      final loggedUser = credential.user;
      if (loggedUser != null) {
        // Update user status and last login time in Firestore
        await FirebaseFirestore.instance.collection('users').doc(loggedUser.uid).set({
          'email': loggedUser.email,
          'uid': loggedUser.uid,
          'password': password,
          'status': 'online',
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final credential = await _authService.registerWithEmailAndPassword(email.trim(), password);
      final registeredUser = credential.user;
      if (registeredUser != null) {
        // Save user profile data to Firestore with online status and timestamps
        await FirebaseFirestore.instance.collection('users').doc(registeredUser.uid).set({
          'email': registeredUser.email,
          'uid': registeredUser.uid,
          'password': password,
          'status': 'online',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final currentUserId = _user?.uid;
    if (currentUserId != null) {
      try {
        // Update user status to offline in Firestore before signing out
        await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
          'status': 'offline',
          'lastLogoutAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Failed to update offline status: $e');
      }
    }

    await _authService.signOut();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  // Helper method to parse Firebase Auth Exception codes into user-friendly messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    debugPrint('FirebaseAuthException caught: [Code: ${e.code}] [Message: ${e.message}]');
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak (must be at least 6 characters).';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Console.';
      case 'configuration-not-found':
        return 'Authentication is not enabled for this project in the Firebase Console. Please turn it on.';
      case 'channel-error':
        return 'Network or input channel error. Please check your credentials.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connectivity.';
      default:
        // Return code along with message to make configuration debugging easier
        return '${e.code.toUpperCase()}: ${e.message ?? 'Authentication failed.'}';
    }
  }
}
