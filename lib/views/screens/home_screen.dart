import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../services/book_service.dart';
import '../../models/book/book.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Add sample books to Firestore
  Future<void> addBook() async {
    final books = [
      {
        'title': 'Introduction to IOT',
        'author':
            'Sudip Misra (Author), Anandarup Mukherjee (Author), Arijit Roy (Author)',
        'price': 1000,
        'coverUrl':
            'https://m.media-amazon.com/images/I/61qeFyTyaKL._SL1200_.jpg',
      },
      {
        'title': 'إحياء علوم الدين',
        'author': 'أبو حامد الغزالي',
        'price': 800,
        'coverUrl':
            'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1261239965i/7361323.jpg',
      },
      {
        'title': 'Invent Your Own Computer Games with Python, 4th Edition ',
        'author': 'Al Sweigart',
        'price': 1500,
        'coverUrl':
            'https://images-na.ssl-images-amazon.com/images/I/51mpkckeu4L.jpg',
      },
      {
        'title': 'السيرة النبوية',
        'author': 'أبو حامد الغزالي',
        'price': 1500,
        'coverUrl':
            'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1309302700i/7495363.jpg',
      },
      {
        'title': 'System Analysis and Design',
        'author': 'Raghu K.N',
        'price': 1500,
        'coverUrl':
            'https://m.media-amazon.com/images/I/51tUeMt8v4L._SX342_SY445_.jpg',
      },
    ];

    try {
      for (var book in books) {
        // Check if book with same title already exists
        final existingBooks = await FirebaseFirestore.instance
            .collection('books')
            .where('title', isEqualTo: book['title'])
            .get();

        if (existingBooks.docs.isEmpty) {
          // Only add if book doesn't exist
          await FirebaseFirestore.instance.collection('books').add(book);
          print('Book added: ${book['title']}');
        } else {
          print('Book already exists: ${book['title']}');
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Books added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding books: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    addBook(); // Remove or comment out after books are added to avoid duplicates
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final padding = isSmallScreen ? 16.0 : 24.0;
    final maxWidth = isSmallScreen ? size.width : 1200.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).pushNamed('/favorites');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed('/purchases');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const SizedBox(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _searchQuery.isEmpty
                      ? FirebaseFirestore.instance
                          .collection('books')
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('books')
                          .where('title', isGreaterThanOrEqualTo: _searchQuery)
                          .where('title',
                              isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final books = snapshot.data!.docs;

                    if (books.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No books available'
                                  : 'No books found for "$_searchQuery"',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 2 : 4,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: isSmallScreen ? 16 : 24,
                        mainAxisSpacing: isSmallScreen ? 16 : 24,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book =
                            books[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/book-details',
                              arguments: books[index].id,
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    child: Image.network(
                                      book['coverUrl'] ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/91DRoRb2yoL._SL1500_.jpg',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(isSmallScreen ? 8 : 12),
                                    child: SingleChildScrollView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            book['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 14 : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                              height: isSmallScreen ? 4 : 8),
                                          Text(
                                            book['author'] ?? '',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 12 : 14,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                              height: isSmallScreen ? 4 : 8),
                                          Text(
                                            '\$${book['price']?.toStringAsFixed(2) ?? '0.00'}',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 14 : 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookSearchDelegate extends SearchDelegate {
  final Function(String) onBookTap;

  BookSearchDelegate({
    required this.onBookTap,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    return FutureBuilder<List<Book>>(
      future: BookService.searchBooks(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final books = snapshot.data ?? [];
        if (books.isEmpty) {
          return const Center(child: Text('No books found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ListTile(
              leading: Image.network(
                book.coverUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.book, size: 50);
                },
              ),
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () {
                onBookTap(book.id);
                close(context, null);
              },
            );
          },
        );
      },
    );
  }
}
