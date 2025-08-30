import 'package:hive_flutter/hive_flutter.dart';
import '../../models/book/book.dart';

class LocalBookService {
  static const String _boxName = 'books';
  late Box<Book> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BookAdapter());
    }
    _box = await Hive.openBox<Book>(_boxName);
  }

  Future<void> saveBook(Book book) async {
    await _box.put(book.id, book);
  }

  Future<void> saveBooks(List<Book> books) async {
    final Map<String, Book> entries = {for (var book in books) book.id: book};
    await _box.putAll(entries);
  }

  Book? getBook(String id) {
    return _box.get(id);
  }

  List<Book> getAllBooks() {
    return _box.values.toList();
  }

  Future<void> deleteBook(String id) async {
    await _box.delete(id);
  }

  Future<void> clearBooks() async {
    await _box.clear();
  }

  List<Book> getFavoriteBooks() {
    return _box.values.where((book) => book.isFavorite).toList();
  }

  List<Book> getPurchasedBooks() {
    return _box.values.where((book) => book.isPurchased).toList();
  }

  List<Book> searchBooks(String query) {
    query = query.toLowerCase();
    return _box.values
        .where((book) =>
            book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query))
        .toList();
  }

  List<Book> getBooksByCategory(String category) {
    return _box.values
        .where((book) => book.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Stream<List<Book>> watchBooks() {
    return _box.watch().map((_) => getAllBooks());
  }

  Stream<Book?> watchBook(String id) {
    return _box.watch(key: id).map((_) => getBook(id));
  }

  bool get isInitialized => _box.isOpen;

  Future<void> dispose() async {
    if (_box.isOpen) {
      await _box.close();
    }
  }
}
