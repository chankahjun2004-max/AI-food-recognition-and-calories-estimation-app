import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserModel &&
            other.id == id &&
            other.name == name &&
            other.email == email);
  }

  @override
  int get hashCode => Object.hash(id, name, email);

  // -------------------------
  // Firebase singletons
  // -------------------------
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  @visibleForTesting
  static void setMockInstances(
      FirebaseAuth mockAuth, FirebaseFirestore mockDb) {
    _auth = mockAuth;
    _db = mockDb;
  }

  static CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // -------------------------
  // Auth / DB methods
  // -------------------------

  /// Email+Password login
  static Future<void> login(String email, String password) async {
    // Guard against weird state where a user is already signed in
    // (doesn't usually hurt, but can reduce confusing edge cases).
    if (_auth.currentUser != null) {
      await _auth.signOut();
    }

    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 20));
      return;
    } on FirebaseAuthException catch (e) {
      // Sometimes on certain environments Firebase returns a vague unknown error.
      // A single retry often resolves transient failures.
      if (e.code == 'unknown' || e.code == 'internal-error') {
        try {
          await Future.delayed(const Duration(milliseconds: 600));
          await _auth
              .signInWithEmailAndPassword(email: email, password: password)
              .timeout(const Duration(seconds: 20));
          return;
        } catch (_) {
          // fall through to friendly message below
        }
      }
      throw _friendlyAuthMessage(e);
    } on TimeoutException {
      throw 'Network timeout. Please try again.';
    }
  }

  /// Email+Password signup.
  ///
  /// Creates the account in Firebase Auth (this is the real "signup").
  /// Then it *tries* to store a basic profile in Firestore: users/{uid}.
  /// If Firestore/profile sync fails (rules / offline / timeout), signup still succeeds
  /// so your UI won't keep buffering or show a false failure.
  static Future<void> signup(String name, String email, String password) async {
    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 20));

      final user = cred.user;
      if (user == null) {
        throw 'Account created but user is null.';
      }

      // Optional: store name in FirebaseAuth profile (best-effort)
      try {
        await user.updateDisplayName(name).timeout(const Duration(seconds: 10));
      } catch (_) {
        // ignore
      }

      // Save profile in Firestore (best-effort; DO NOT block signup)
      try {
        await _users.doc(user.uid).set({
          'id': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 20));
      } on TimeoutException {
        // Do not throw: Auth signup already succeeded.
      } on FirebaseException {
        // Do not throw: rules/not-enabled/etc. shouldn't block Auth signup.
      }

      // Many apps want "signup -> go login", so sign out to avoid confusing state.
      // If you prefer auto-login after signup, remove this line.
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _friendlyAuthMessage(e);
    } on TimeoutException {
      // If we timed out during Auth account creation, that *is* a real failure.
      throw 'Network timeout. Please try again.';
    }
  }

  /// Send reset email (Firebase hosted reset flow)
  static Future<void> sendPasswordReset(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw 'Please enter your email.';
    }

    try {
      await _auth
          .sendPasswordResetEmail(email: trimmed)
          .timeout(const Duration(seconds: 15));
    } on FirebaseAuthException catch (e) {
      throw _friendlyAuthMessage(e);
    } on TimeoutException {
      throw 'Network timeout. Please try again.';
    }
  }

  /// Change password (re-auth required)
  static Future<void> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      final currentEmail = user?.email;
      if (user == null || currentEmail == null) {
        throw 'No logged-in user.';
      }

      final credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: oldPassword,
      );

      await user
          .reauthenticateWithCredential(credential)
          .timeout(const Duration(seconds: 15));
      await user
          .updatePassword(newPassword)
          .timeout(const Duration(seconds: 15));
    } on FirebaseAuthException catch (e) {
      throw _friendlyAuthMessage(e);
    } on TimeoutException {
      throw 'Network timeout. Please try again.';
    }
  }

  static Future<void> logout() async {
    // If user explicitly logs out, turn off Remember Me.
    await setRememberMe(false);
    await _auth.signOut();
  }

  static String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication failed: ${e.code}';
    }
  }

  // -------------------------
  // User Preferences
  // -------------------------
  static const _rememberMeKey = 'remember_me';

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // -- Other Methods from UML --
  void changePersonalDetail() {
    // TODO: Implement changePersonalDetail
  }

  void connect() {
    // TODO: Implement connect
  }

  void close() {
    // TODO: Implement close
  }
}
