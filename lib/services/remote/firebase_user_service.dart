import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_profile.dart';

class FirebaseUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user profile
  Future<UserProfile> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User profile not found');
    }
    return UserProfile.fromJson({...doc.data()!, 'id': doc.id});
  }

  // Stream user profile
  Stream<UserProfile> streamUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => UserProfile.fromJson({...doc.data()!, 'id': doc.id}));
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Get user's book ratings
  Future<Map<String, double>> getUserBookRatings(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      return {};
    }
    final data = doc.data()!;
    final ratings = data['bookRatings'] as Map<String, dynamic>? ?? {};
    return ratings
        .map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  // Get user's purchase history
  Stream<List<Map<String, dynamic>>> getPurchaseHistory(String userId) {
    return _firestore
        .collection('purchase_records')
        .where('userId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Get user's favorite books
  Stream<List<String>> getFavoriteBookIds(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['bookId'] as String).toList();
    });
  }

  // Record user activity
  Future<void> recordActivity({
    required String userId,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    await _firestore.collection('user_activities').add({
      'userId': userId,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'metadata': metadata,
    });
  }

  // Get user's activity history
  Stream<List<Map<String, dynamic>>> getActivityHistory(String userId) {
    return _firestore
        .collection('user_activities')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Delete user account
  Future<void> deleteUserAccount(String userId) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != userId) {
      throw Exception('Unauthorized to delete this account');
    }

    // Delete user data from Firestore
    await _firestore.collection('users').doc(userId).delete();

    // Delete user's favorites
    final favorites = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in favorites.docs) {
      await doc.reference.delete();
    }

    // Delete user's purchase records
    final purchases = await _firestore
        .collection('purchase_records')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in purchases.docs) {
      await doc.reference.delete();
    }

    // Delete user's activities
    final activities = await _firestore
        .collection('user_activities')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in activities.docs) {
      await doc.reference.delete();
    }

    // Delete Firebase Auth user
    await user.delete();
  }

  // Remove book from favorites
  Future<void> removeFavorite(String userId, String bookId) async {
    final favorites = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .get();

    for (var doc in favorites.docs) {
      await doc.reference.delete();
    }

    // Update user's favorite count
    await _firestore.collection('users').doc(userId).update({
      'favoriteCount': FieldValue.increment(-1),
    });
  }
}
