import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/remote/firebase_user_service.dart';
import '../../utils/constants.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isLoading = false;
  bool _isFavorite = false;
  bool _isPurchased = false;
  Map<String, dynamic>? _book;
  final _userService = FirebaseUserService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBookDetails();
  }

  Future<void> _loadBookDetails() async {
    setState(() => _isLoading = true);

    try {
      final bookId = ModalRoute.of(context)!.settings.arguments as String;
      final bookDoc = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();

      if (!bookDoc.exists) {
        throw Exception('Book not found');
      }

      final currentUser = await AuthService.getCurrentUser();
      if (currentUser != null) {
        // Check if book is in favorites
        final favoriteDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .collection('favorites')
            .doc(bookId)
            .get();

        // Check if book is purchased
        final purchaseDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .collection('purchases')
            .doc(bookId)
            .get();

        if (mounted) {
          setState(() {
            _book = bookDoc.data();
            _isFavorite = favoriteDoc.exists;
            _isPurchased = purchaseDoc.exists;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _book = bookDoc.data();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final bookId = ModalRoute.of(context)!.settings.arguments as String;

      if (_isFavorite) {
        await _userService.removeFavorite(currentUser.id, bookId);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .collection('favorites')
            .doc(bookId)
            .set({
          'addedAt': FieldValue.serverTimestamp(),
          'bookId': bookId,
          'title': _book!['title'],
          'author': _book!['author'],
          'coverUrl': _book!['coverUrl'],
          'price': _book!['price'],
        });
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _purchaseBook() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final bookId = ModalRoute.of(context)!.settings.arguments as String;
      final purchaseDate = DateTime.now();

      // Add to purchases collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id)
          .collection('purchases')
          .doc(bookId)
          .set({
        'purchasedAt': purchaseDate,
        'bookId': bookId,
        'title': _book!['title'],
        'author': _book!['author'],
        'coverUrl': _book!['coverUrl'],
        'price': _book!['price'],
        'purchaseDate': purchaseDate.toIso8601String(),
      });

      // Add to purchase history for invoice
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id)
          .collection('purchase_history')
          .add({
        'bookId': bookId,
        'title': _book!['title'],
        'author': _book!['author'],
        'price': _book!['price'],
        'purchaseDate': purchaseDate.toIso8601String(),
        'invoiceNumber': 'INV-${DateTime.now().millisecondsSinceEpoch}',
      });

      if (mounted) {
        setState(() {
          _isPurchased = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book purchased successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _book == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_book == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Book Details'),
        ),
        body: const Center(
          child: Text('Book not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _book!['coverUrl'] ?? '',
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.book,
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Book title
            Text(
              _book!['title'] ?? '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            // Author
            Text(
              _book!['author'] ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            // Price
            Text(
              '\$${(_book!['price'] ?? 0).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  label: Text(_isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                if (!_isPurchased)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _purchaseBook,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Purchase'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
