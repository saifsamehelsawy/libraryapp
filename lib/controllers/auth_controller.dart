import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_profile.dart';
import '../models/user/user_activity.dart';

class AuthController {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Get current user profile
  Stream<UserProfile?> get currentUserProfile {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map(
          (doc) => doc.exists
              ? UserProfile.fromJson({'id': doc.id, ...doc.data()!})
              : null,
        );
  }

  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserProfile> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Update last login
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      // Get user profile
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        throw Exception('User profile not found');
      }

      return UserProfile.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  Future<UserProfile> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Create user profile
      final userProfile = UserProfile(
        id: user.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toJson());

      return userProfile;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data
  Future<UserProfile> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }
      return UserProfile.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? avatarUrl,
    String? bio,
    String? address,
    Map<String, dynamic>? preferences,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (bio != null) updates['bio'] = bio;
    if (address != null) updates['address'] = address;
    if (preferences != null) updates['preferences'] = preferences;

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  // Get user activity history
  Stream<List<UserActivity>> getUserActivityHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('user_activities')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserActivity.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    });
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Delete user data
    await _firestore.collection('users').doc(user.uid).delete();
    await _firestore
        .collection('user_activities')
        .where('userId', isEqualTo: user.uid)
        .get()
        .then(
          (snapshot) =>
              Future.wait(snapshot.docs.map((doc) => doc.reference.delete())),
        );

    // Delete user authentication
    await user.delete();
  }
}
