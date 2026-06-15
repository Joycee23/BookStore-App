import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/order.dart' as model;

class OrderProvider with ChangeNotifier {
  List<model.MyOrder> _orders = [];
  List<model.MyOrder> get orders => _orders;

  String get _apiUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  Future<void> fetchOrders(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/api/orders/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _orders = data.map((json) => model.MyOrder.fromMap(json['id'], json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi tải danh sách đơn hàng: $e");
    }
  }

  // Việc tạo đơn hàng (placeOrder) giờ đây được xử lý qua API Checkout PayOS ở checkout_screen.dart
}
