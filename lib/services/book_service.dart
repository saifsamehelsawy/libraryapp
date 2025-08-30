import 'package:shared_preferences/shared_preferences.dart';
import '../models/book/book.dart';

class BookService {
  static const String _booksKey = 'books_data';

  static Future<List<Book>> getBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getStringList(_booksKey) ?? [];

    if (booksJson.isEmpty) {
      // Initialize with sample data if empty
      final sampleBooks = List.generate(
        10,
        (index) => Book(
          id: 'book_$index',
          title: 'Book ${index + 1}',
          author: 'Author ${index + 1}',
          description:
              'This is a sample book description for Book ${index + 1}.',
          coverUrl: 'https://picsum.photos/200/300?random=$index',
          price: 19.99,
          rating: 4.5,
          reviewCount: 100,
          publishedDate: DateTime.now().subtract(Duration(days: index * 30)),
          category: 'Fiction',
          pageCount: 300,
          language: 'English',
          publisher: 'Sample Publisher',
          isbn: '978-3-16-148410-$index',
        ),
      );
      await saveBooks(sampleBooks);
      return sampleBooks;
    }

    return booksJson.map((json) {
      final parts = json.split('|');
      return Book(
        id: parts[0],
        title: parts[1],
        author: parts[2],
        description: parts[3],
        coverUrl: parts[4],
        price: double.parse(parts[5]),
        rating: double.parse(parts[6]),
        reviewCount: int.parse(parts[7]),
        isFavorite: parts[8] == 'true',
        isPurchased: parts[9] == 'true',
        publishedDate: DateTime.parse(parts[10]),
        category: parts[11],
        pageCount: int.parse(parts[12]),
        language: parts[13],
        publisher: parts[14],
        isbn: parts[15],
      );
    }).toList();
  }

  static Future<List<Book>> searchBooks(String query) async {
    final books = await getBooks();
    if (query.isEmpty) return books;

    final lowercaseQuery = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(lowercaseQuery) ||
          book.author.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = books
        .map((book) =>
            '${book.id}|${book.title}|${book.author}|${book.description}|${book.coverUrl}|${book.price}|${book.rating}|${book.reviewCount}|${book.isFavorite}|${book.isPurchased}|${book.publishedDate.toIso8601String()}|${book.category}|${book.pageCount}|${book.language}|${book.publisher}|${book.isbn}')
        .toList();

    await prefs.setStringList(_booksKey, booksJson);
  }
}
