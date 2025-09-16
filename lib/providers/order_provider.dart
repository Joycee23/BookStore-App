import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as model; // đặt biệt danh để tránh trùng tên
import '../utils/order_utils.dart';

class OrderProvider with ChangeNotifier {
  List<model.MyOrder> _orders = [];
  List<model.MyOrder> get orders => _orders;

  Future<void> fetchOrders(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    _orders = snapshot.docs
        .map((doc) => model.MyOrder.fromMap(doc.id, doc.data()))
        .toList();
    notifyListeners();
  }

  Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double originalAmount,
    required bool usedDiscount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập.');

    final userId = user.uid;
    final orderId = OrderUtils.generateOrderId();

    final order = model.MyOrder(
      id: orderId,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      originalAmount: originalAmount,
      usedDiscount: usedDiscount,
      createdAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .set(order.toMap());
  }
}
