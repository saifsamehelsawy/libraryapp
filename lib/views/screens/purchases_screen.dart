import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _purchases = [];

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final purchasesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('purchases')
          .get();

      if (!mounted) return;

      setState(() {
        _purchases = purchasesSnapshot.docs.map((doc) {
          final data = doc.data();
          print('Purchase data for ${doc.id}: $data'); // Debug log
          // Ensure we have all required fields
          return {
            'bookId': doc.id,
            'title': data['title'] ?? 'Unknown Book',
            'author': data['author'] ?? 'Unknown Author',
            'coverUrl': data['coverUrl'] ?? '',
            'price': data['price'] ?? 0.0,
            'purchaseDate':
                data['purchaseDate'] ?? DateTime.now().toIso8601String(),
          };
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading purchases: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePurchase(String bookId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Delete from purchases
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('purchases')
          .doc(bookId)
          .delete();

      // Delete from purchase_history
      final purchaseHistoryQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('purchase_history')
          .where('bookId', isEqualTo: bookId)
          .get();

      for (var doc in purchaseHistoryQuery.docs) {
        await doc.reference.delete();
      }

      if (!mounted) return;
      setState(() {
        _purchases.removeWhere((book) => book['bookId'] == bookId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book removed from purchases'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing purchase: ${e.toString()}')),
      );
    }
  }

  void _onBookTap(String bookId) {
    Navigator.pushNamed(
      context,
      '/book-details',
      arguments: bookId,
    );
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
        title: const Text('Purchases'),
      ),
      body: _purchases.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'No purchases yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Purchase books to see them here',
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
              itemCount: _purchases.length,
              itemBuilder: (context, index) {
                final book = _purchases[index];
                final bookId = book['bookId'] as String?;
                if (bookId == null) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.only(
                      bottom: AppConstants.defaultPadding),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(AppConstants.smallPadding),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        book['coverUrl'] ?? '',
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/91DRoRb2yoL.SL1500.jpg',
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    title: Text(
                      book['title'] ?? 'Unknown Book',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book['author'] ?? 'Unknown Author'),
                        const SizedBox(height: 4),
                        Text(
                          'Purchased on: ${book['purchaseDate']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${(book['price'] ?? 0).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _deletePurchase(bookId),
                          tooltip: 'Remove from purchases',
                        ),
                      ],
                    ),
                    onTap: () => _onBookTap(bookId),
                  ),
                );
              },
            ),
    );
  }
}
