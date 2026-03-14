import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }



  static FirebaseAuth? _auth;
  static FirebaseFirestore? _db;

  static FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  static FirebaseFirestore get db {
    _db ??= FirebaseFirestore.instance;
    return _db!;
  }

  static CollectionReference<Map<String, dynamic>> get _users =>
      db.collection('users');

// ----------------------------
// Connection Control
// ----------------------------

  static void connect() {
    print('[UserModel] connect() called');
    _auth ??= FirebaseAuth.instance;
    _db ??= FirebaseFirestore.instance;
  }

//testing part
  static void setMockInstances(FirebaseAuth? mockAuth, FirebaseFirestore? mockDb) {
    _auth = mockAuth;
    _db = mockDb;
  }

  static void close() {
    print('[UserModel] close() called');
    _auth = null;
    _db = null;
  }

// ----------------------------
// Authentication Functions
// ----------------------------

  static Future<void> signup(
      String name, String email, String password) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );


    await _users.doc(credential.user!.uid).set({
    'name': name,
    'email': email,
    });


  }

  static Future<void> login(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> logout() async {
    await auth.signOut();
  }

  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final user = auth.currentUser;


    if (user == null) {
    throw Exception('User not logged in');
    }

    final cred = EmailAuthProvider.credential(
    email: user.email!,
    password: currentPassword,
    );

    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);


    }

  static Future<void> sendPasswordReset(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }



  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }



  static Future<UserModel?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();


    if (!snapshot.exists) return null;

    return UserModel.fromMap(snapshot.data()!, snapshot.id);


  }

  static Future<UserModel?> getCurrentUserProfile() async {
    final user = auth.currentUser;


    if (user == null) return null;

    final snapshot = await _users.doc(user.uid).get();

    if (!snapshot.exists) return null;

    return UserModel.fromMap(snapshot.data()!, snapshot.id);


  }

  static Future<void> updateUserName(String uid, String name) async {
    await _users.doc(uid).update({'name': name});
  }

  static Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }


  static User? getCurrentFirebaseUser() {
    return auth.currentUser;
  }

  static String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  static bool isLoggedIn() {
    return auth.currentUser != null;
  }
}
