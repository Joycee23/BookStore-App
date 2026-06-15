import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, String id) {
    return CartItem(
      id: id,
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  double get totalPrice => _items.values.fold(0, (sum, item) => sum + (item.price * item.quantity));

  String get _apiUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  Future<void> loadCartFromBackend(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/api/cart/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List itemsList = data['items'] ?? [];
        _items = {};
        for (var item in itemsList) {
          final book = item['book'];
          _items[book['id']] = CartItem(
            id: book['id'],
            title: book['title'],
            price: (book['price'] ?? 0).toDouble(),
            quantity: item['quantity'],
            imageUrl: book['imageUrl'],
          );
        }
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi khi tải giỏ hàng: $e");
    }
  }

  Future<void> addItem(String userId, String bookId, String title, double price, String imageUrl) async {
    // Optimistic update
    if (_items.containsKey(bookId)) {
      _items.update(bookId, (existing) => CartItem(
        id: existing.id, title: existing.title, price: existing.price,
        quantity: existing.quantity + 1, imageUrl: existing.imageUrl,
      ));
    } else {
      _items.putIfAbsent(bookId, () => CartItem(
        id: bookId, title: title, price: price, quantity: 1, imageUrl: imageUrl,
      ));
    }
    notifyListeners();

    // Sync with backend
    try {
      await http.post(
        Uri.parse('$_apiUrl/api/cart/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'bookId': bookId, 'quantity': _items[bookId]!.quantity}),
      );
    } catch (e) {
      print("Lỗi khi thêm vào giỏ: $e");
    }
  }

  Future<void> removeItem(String userId, String bookId) async {
    _items.remove(bookId);
    notifyListeners();

    try {
      await http.delete(Uri.parse('$_apiUrl/api/cart/$userId/item/$bookId'));
    } catch (e) {
      print("Lỗi khi xóa khỏi giỏ: $e");
    }
  }

  Future<void> updateItemQuantity(String userId, String bookId, int newQuantity) async {
    if (_items.containsKey(bookId)) {
      _items.update(bookId, (existing) => CartItem(
        id: existing.id, title: existing.title, price: existing.price,
        quantity: newQuantity, imageUrl: existing.imageUrl,
      ));
      notifyListeners();

      try {
        await http.post(
          Uri.parse('$_apiUrl/api/cart/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'bookId': bookId, 'quantity': newQuantity}),
        );
      } catch (e) {
        print("Lỗi khi cập nhật số lượng: $e");
      }
    }
  }
}
