import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final email = user.email;

      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: email)
          .orderBy('timestamp', descending: true)
          .get();

      final List<Map<String, dynamic>> loadedOrders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        loadedOrders.add({
          'id': doc.id,
          'totalAmount': data['totalAmount'],
          'timestamp': data['timestamp'].toDate(),
          'items': List<Map<String, dynamic>>.from(data['items']),
          'address': data['address'],
          'fullName': data['fullName'],
          'phoneNumber': data['phoneNumber'],
          'paymentMethod': data['paymentMethod'],
        });
      }

      setState(() {
        _orders = loadedOrders;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(title: Text('Đơn hàng của tôi')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('Chưa có đơn hàng nào'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (ctx, i) {
                    final order = _orders[i];
                    final createdAt = order['timestamp'];
                    final items = order['items'] as List;

                    return Card(
                      margin: EdgeInsets.all(12),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mã đơn: ${order['id']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Text(
                                  "Ngày đặt: ${DateFormat('dd/MM/yyyy – HH:mm').format(createdAt)}",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(),
                            Text(
                              "Sản phẩm:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 6),
                            ...items.map<Widget>((item) {
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['imageUrl'] ?? '',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        Icon(Icons.image_not_supported),
                                  ),
                                ),
                                title: Text(item['title'] ?? ''),
                                subtitle: Text(
                                  "Số lượng: ${item['quantity']} | Giá: ${currencyFormat.format(item['price'])}",
                                ),
                              );
                            }).toList(),
                            SizedBox(height: 12),
                            Divider(),
                            Text(
                              "Thông tin người nhận:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 18, color: Colors.grey[700]),
                                SizedBox(width: 8),
                                Text(order['fullName']),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 18, color: Colors.grey[700]),
                                SizedBox(width: 8),
                                Text(order['phoneNumber']),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on,
                                    size: 18, color: Colors.grey[700]),
                                SizedBox(width: 8),
                                Expanded(child: Text(order['address'])),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.payment,
                                    size: 18, color: Colors.grey[700]),
                                SizedBox(width: 8),
                                Text("Thanh toán: ${order['paymentMethod']}"),
                              ],
                            ),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Tổng tiền: ${currencyFormat.format(order['totalAmount'])}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
