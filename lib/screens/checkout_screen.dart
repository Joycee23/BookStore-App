import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isConfirmingOrder = false;  // Biến kiểm tra trạng thái xác nhận

  // Hàm lấy thông tin người dùng từ Firestore
  Future<Map<String, dynamic>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return docSnapshot.data() ?? {};
    }
    return {};
  }

  // Hàm xác nhận đơn hàng và lưu vào Firestore
  Future<void> _confirmOrder(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userInfo = await _getUserInfo();
      
      final orderData = {
        'userId': user.uid,
        'userName': userInfo['name'] ?? 'Không có tên',
        'userPhone': userInfo['phone'] ?? 'Không có số điện thoại',
        'userAddress': userInfo['address'] ?? 'Không có địa chỉ',
        'orderDate': Timestamp.now(),
        'status': 'Chờ vận chuyển', // Trạng thái đơn hàng ban đầu
        'items': cart.items.values.map((item) => {
          'productName': item.title,
          'productPrice': item.price,
          'quantity': item.quantity,
        }).toList(),
        'totalPrice': cart.totalPrice,
      };

      // Lưu đơn hàng vào Firestore
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Thông báo đã đặt hàng thành công
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đặt hàng thành công")));

      // Xóa giỏ hàng sau khi thanh toán
      cart.clearCart();

      // Quay lại trang giỏ hàng
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isConfirmingOrder
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thông tin người nhận", style: TextStyle(fontWeight: FontWeight.bold)),
                  // Hiển thị thông tin người dùng nếu có
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getUserInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Lỗi tải thông tin người dùng');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('Không có thông tin người dùng');
                      }

                      final userInfo = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tên: ${userInfo['name'] ?? 'Không có tên'}"),
                          Text("Số điện thoại: ${userInfo['phone'] ?? 'Không có số điện thoại'}"),
                          Text("Địa chỉ: ${userInfo['address'] ?? 'Không có địa chỉ'}"),
                          SizedBox(height: 20),
                          Text("Sản phẩm trong giỏ hàng:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Column(
                            children: cart.items.values.map((item) {
                              return ListTile(
                                title: Text(item.title),
                                subtitle: Text("Giá: \$${item.price} x ${item.quantity}"),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                          Text("Tổng tiền: \$${cart.totalPrice.toStringAsFixed(2)}", 
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Xác nhận và thanh toán
                              _confirmOrder(context);
                            },
                            child: Text("Xác nhận và thanh toán"),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tổng tiền: \$${cart.totalPrice.toStringAsFixed(2)}", 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Chuyển đến bước xác nhận thông tin
                      setState(() {
                        _isConfirmingOrder = true;
                      });
                    },
                    child: Text("Tiến hành thanh toán"),
                  ),
                ],
              ),
      ),
    );
  }
}
