import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book/book.dart';

class FirebaseBookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  Stream<List<Book>> getBooks() {
    return _firestore.collection(_collection).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Book.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Future<Book?> getBook(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Book.fromJson({'id': doc.id, ...doc.data()!});
  }

  Stream<List<Book>> getFavoriteBooks(String userId) {
    return _firestore
        .collection(_collection)
        .where('favoritedBy', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Stream<List<Book>> getPurchasedBooks(String userId) {
    return _firestore
        .collection(_collection)
        .where('purchasedBy', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Future<void> addBook(Book book) async {
    await _firestore.collection(_collection).add(book.toJson());
  }

  Future<void> updateBook(Book book) async {
    await _firestore.collection(_collection).doc(book.id).update(book.toJson());
  }

  Future<void> deleteBook(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> toggleFavorite(String bookId, String userId) async {
    final doc = await _firestore.collection(_collection).doc(bookId).get();
    if (!doc.exists) return;

    final List<String> favoritedBy =
        List<String>.from(doc.data()?['favoritedBy'] ?? []);

    if (favoritedBy.contains(userId)) {
      favoritedBy.remove(userId);
    } else {
      favoritedBy.add(userId);
    }

    await doc.reference.update({'favoritedBy': favoritedBy});
  }

  Future<void> purchaseBook(String bookId, String userId) async {
    final doc = await _firestore.collection(_collection).doc(bookId).get();
    if (!doc.exists) return;

    final List<String> purchasedBy =
        List<String>.from(doc.data()?['purchasedBy'] ?? []);

    if (!purchasedBy.contains(userId)) {
      purchasedBy.add(userId);
      await doc.reference.update({
        'purchasedBy': purchasedBy,
        'availableStock': FieldValue.increment(-1),
      });
    }
  }

  Stream<List<Book>> searchBooks(String query) {
    return _firestore
        .collection(_collection)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Stream<List<Book>> getBooksByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Future<void> rateBook(String bookId, String userId, double rating) async {
    final doc = await _firestore.collection(_collection).doc(bookId).get();
    if (!doc.exists) return;

    final Map<String, dynamic> ratings =
        Map<String, dynamic>.from(doc.data()?['ratings'] ?? {});
    ratings[userId] = rating;

    final double averageRating =
        ratings.values.fold(0.0, (total, value) => total + value) /
            ratings.length;

    await doc.reference.update({
      'ratings': ratings,
      'rating': averageRating,
      'reviewCount': ratings.length,
    });
  }
}
