import 'package:flutter/foundation.dart';
import '../models/book/book.dart';
import '../services/remote/firebase_book_service.dart';
import '../services/local/local_book_service.dart';

class BookController extends ChangeNotifier {
  final FirebaseBookService _bookService;
  final LocalBookService _localBookService;

  List<Book> _books = [];
  List<Book> _favoriteBooks = [];
  List<Book> _purchasedBooks = [];
  Book? _selectedBook;
  bool _isLoading = false;
  String? _error;

  BookController(this._bookService, this._localBookService) {
    _init();
  }

  List<Book> get books => _books;
  List<Book> get favoriteBooks => _favoriteBooks;
  List<Book> get purchasedBooks => _purchasedBooks;
  Book? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _init() {
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load from local storage first
      _books = _localBookService.getAllBooks();
      _favoriteBooks = _localBookService.getFavoriteBooks();
      _purchasedBooks = _localBookService.getPurchasedBooks();
      notifyListeners();

      // Then load from Firebase and update local storage
      _bookService.getBooks().listen((books) {
        _books = books;
        _localBookService.saveBooks(books);
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBooks() async {
    await _loadBooks();
  }

  Future<void> selectBook(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Try local storage first
      _selectedBook = _localBookService.getBook(id);
      notifyListeners();

      // Then get from Firebase
      final book = await _bookService.getBook(id);
      if (book != null) {
        _selectedBook = book;
        await _localBookService.saveBook(book);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String bookId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _bookService.toggleFavorite(bookId, userId);
      await refreshBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> purchaseBook(String bookId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _bookService.purchaseBook(bookId, userId);
      await refreshBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rateBook(String bookId, String userId, double rating) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _bookService.rateBook(bookId, userId, rating);
      await refreshBooks();
      if (_selectedBook?.id == bookId) {
        await selectBook(bookId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (query.isEmpty) {
        await refreshBooks();
        return;
      }

      // Try local search first
      _books = _localBookService.searchBooks(query);
      notifyListeners();

      // Then search in Firebase
      _bookService.searchBooks(query).listen((books) {
        _books = books;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCategory(String category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (category.isEmpty) {
        await refreshBooks();
        return;
      }

      // Try local filter first
      _books = _localBookService.getBooksByCategory(category);
      notifyListeners();

      // Then filter in Firebase
      _bookService.getBooksByCategory(category).listen((books) {
        _books = books;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
