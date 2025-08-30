import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PurchaseService {
  static const String _purchasesKey = 'purchases';
  static final List<Map<String, dynamic>> _purchases = [];
  static bool _isLoaded = false;

  static List<Map<String, dynamic>> get purchases =>
      List.unmodifiable(_purchases);

  static Future<List<Map<String, dynamic>>> getPurchases() async {
    if (!_isLoaded) {
      await loadPurchases();
    }
    return purchases;
  }

  static Future<void> loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasesJson = prefs.getStringList(_purchasesKey) ?? [];
    _purchases.clear();
    _purchases.addAll(
      purchasesJson.map((json) => Map<String, dynamic>.from(jsonDecode(json))),
    );
    _isLoaded = true;
  }

  static Future<void> addPurchase(Map<String, dynamic> purchase) async {
    if (!_isLoaded) {
      await loadPurchases();
    }
    _purchases.add(purchase);
    await _savePurchases();
  }

  static Future<void> removePurchase(String purchaseId) async {
    if (!_isLoaded) {
      await loadPurchases();
    }
    _purchases.removeWhere((purchase) => purchase['id'] == purchaseId);
    await _savePurchases();
  }

  static Future<void> _savePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasesJson =
        _purchases.map((purchase) => jsonEncode(purchase)).toList();
    await prefs.setStringList(_purchasesKey, purchasesJson);
  }

  static Future<bool> hasPurchased(String bookId) async {
    if (!_isLoaded) {
      await loadPurchases();
    }
    return _purchases.any((purchase) => purchase['bookId'] == bookId);
  }

  static Future<void> clearPurchases() async {
    _purchases.clear();
    _isLoaded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_purchasesKey);
  }
}
