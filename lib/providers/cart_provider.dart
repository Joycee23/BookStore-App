import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

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

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalPrice {
    return _items.values.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void addItem(String productId, String title, double price, String imageUrl) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  // 🔥 Firestore: Save Cart
  Future<void> saveCartToFirestore(String userEmail) async {
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(userEmail);

    final cartData = _items.map((key, item) => MapEntry(key, item.toJson()));

    try {
      await cartRef.set({'items': cartData});
      print("Giỏ hàng đã lưu thành công!");
    } catch (e) {
      print("Lỗi khi lưu giỏ hàng: $e");
    }
  }

  // 🔥 Firestore: Load Cart
  Future<void> loadCartFromFirestore(String userEmail) async {
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(userEmail);

    try {
      final snapshot = await cartRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final items = data['items'] as Map<String, dynamic>;

        _items = items.map((key, value) {
          return MapEntry(
            key,
            CartItem.fromJson(value, key),
          );
        });

        notifyListeners();
      } else {
        print("Không tìm thấy giỏ hàng cho người dùng $userEmail.");
      }
    } catch (e) {
      print("Lỗi khi tải giỏ hàng: $e");
    }
  }

  // ✅ Hàm cập nhật số lượng sản phẩm
  void updateItemQuantity(String productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: newQuantity,
          imageUrl: existingItem.imageUrl,
        ),
      );
      notifyListeners();
    }
  }
}
