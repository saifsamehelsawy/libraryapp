import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../widgets/book_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .get();

      if (!mounted) return;

      setState(() {
        _favorites = favoritesSnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onBookTap(String bookId) {
    Navigator.pushNamed(
      context,
      '/book-details',
      arguments: bookId,
    );
  }

  Future<void> _onFavoriteToggle(String bookId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(bookId)
          .delete();

      if (!mounted) return;
      setState(() {
        _favorites.removeWhere((book) => book['bookId'] == bookId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book removed from favorites'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing favorite: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Add books to your favorites to see them here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final book = _favorites[index];
                final bookId = book['bookId'] as String?;
                if (bookId == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppConstants.defaultPadding),
                  child: BookCard(
                    onTap: () => _onBookTap(bookId),
                    title: book['title'] as String? ?? '',
                    author: book['author'] as String? ?? '',
                    coverUrl: book['coverUrl'] as String? ?? '',
                    rating: 0.0,
                    reviewCount: 0,
                    price: (book['price'] as num?)?.toDouble() ?? 0.0,
                    isFavorite: true,
                    onFavoriteToggle: () => _onFavoriteToggle(bookId),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _onFavoriteToggle(bookId),
                      tooltip: 'Remove from favorites',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
