import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userKey = 'user_data';
  static final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final userData = await getUserData(firebaseUser.uid);
      final user = User(
        id: firebaseUser.uid,
        name: userData['name'] ?? firebaseUser.displayName ?? 'User',
        email: firebaseUser.email!,
        photoUrl: userData['photoUrl'] ??
            firebaseUser.photoURL ??
            'https://picsum.photos/200',
        joinedDate:
            (userData['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        favoriteCount: userData['favoriteCount'] ?? 0,
        purchaseCount: userData['purchaseCount'] ?? 0,
      );

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, json.encode(user.toJson()));

      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data() ?? {};
    } catch (e) {
      return {};
    }
  }

  static Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw 'Failed to sign in';
      }

      final userData = await getUserData(firebaseUser.uid);
      final user = User(
        id: firebaseUser.uid,
        name: userData['name'] ?? firebaseUser.displayName ?? 'User',
        email: firebaseUser.email!,
        photoUrl: userData['photoUrl'] ??
            firebaseUser.photoURL ??
            'https://picsum.photos/200',
        joinedDate:
            (userData['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        favoriteCount: userData['favoriteCount'] ?? 0,
        purchaseCount: userData['purchaseCount'] ?? 0,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, json.encode(user.toJson()));

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found with this email';
        case 'wrong-password':
          throw 'Wrong password provided';
        case 'invalid-email':
          throw 'Invalid email address';
        case 'user-disabled':
          throw 'This account has been disabled';
        default:
          throw 'An error occurred. Please try again';
      }
    }
  }

  static Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw 'Failed to create account';
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user document in Firestore
      final user = User(
        id: firebaseUser.uid,
        name: name,
        email: email,
        photoUrl: 'https://picsum.photos/200',
        joinedDate: DateTime.now(),
        favoriteCount: 0,
        purchaseCount: 0,
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toJson());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, json.encode(user.toJson()));

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'An account already exists with this email';
        case 'invalid-email':
          throw 'Invalid email address';
        case 'weak-password':
          throw 'Password is too weak';
        default:
          throw 'An error occurred. Please try again';
      }
    }
  }

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userKey);
    } catch (e) {
      throw 'Failed to sign out';
    }
  }
}
