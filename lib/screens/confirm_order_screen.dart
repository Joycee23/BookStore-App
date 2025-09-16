import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/discount_provider.dart';

class ConfirmOrderScreen extends StatefulWidget {
  @override
  _ConfirmOrderScreenState createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _discountMessage;
  double _discountAmount = 0;
  bool _isDiscountListVisible = false;
  String _selectedDiscountCode = '';

  // Thêm biến lưu phương thức thanh toán
  String _selectedPaymentMethod = "Tiền mặt";

  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    // Nếu AuthProvider có method fetch lại số dư ví thì gọi ở đây để cập nhật số dư mới nhất
    // Provider.of<AuthProvider>(context, listen: false).fetchWalletBalance();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final discountProvider = Provider.of<DiscountProvider>(context);

    final cartItems = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: Text("Xác nhận đặt hàng"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thông tin người nhận",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700])),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.person, "Họ và tên", authProvider.fullName),
                    _buildInfoTile(Icons.email, "Email", authProvider.email ?? ""),
                    _buildInfoTile(Icons.phone, "Số điện thoại", authProvider.phoneNumber),
                    _buildInfoTile(Icons.location_on, "Địa chỉ", authProvider.address),

                    // Dropdown chọn phương thức thanh toán
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.payment, color: Colors.teal),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPaymentMethod,
                              decoration: InputDecoration(
                                labelText: "Thanh toán",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: "Tiền mặt",
                                  child: Text("Tiền mặt"),
                                ),
                                DropdownMenuItem(
                                  value: "Ví của tôi",
                                  child: Text("Ví của tôi"),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Text("Chọn mã giảm giá (nếu có)",
                style: TextStyle(fontSize: 18, color: Colors.teal[700])),
            SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                setState(() {
                  _isDiscountListVisible = !_isDiscountListVisible;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDiscountCode.isEmpty
                          ? 'Chọn mã giảm giá'
                          : _selectedDiscountCode,
                      style: TextStyle(fontSize: 16, color: Colors.teal),
                    ),
                    Icon(_isDiscountListVisible
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down, color: Colors.teal)
                  ],
                ),
              ),
            ),

            if (_isDiscountListVisible) ...[
              SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8)),
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('discountCodes').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi khi tải mã giảm giá'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('Không có mã giảm giá nào'));
                    }

                    var discountCodes = snapshot.data!.docs
                        .map((doc) => doc['discountCodes'] as List<dynamic>)
                        .expand((x) => x)
                        .toList();

                    discountCodes = discountCodes.where((discountCodeData) {
                      var isUsed = discountCodeData['isUsed'] as bool;
                      return !isUsed;
                    }).toList();

                    return ListView.builder(
                      itemCount: discountCodes.length,
                      itemBuilder: (context, index) {
                        var discountCodeData = discountCodes[index];
                        var discountCode = discountCodeData['code'] as String;
                        var amount = (discountCodeData['amount'] as num).toDouble();
                        var expiryDate = discountCodeData['expiryDate'] as String;

                        return ListTile(
                          title: Text(discountCode),
                          subtitle: Text("Giảm: ${currencyFormat.format(amount)} - HSD: $expiryDate"),
                          onTap: () async {
                            setState(() {
                              _selectedDiscountCode = discountCode;
                              _isDiscountListVisible = false;
                            });

                            bool isExpired = DateTime.parse(expiryDate).isBefore(DateTime.now());

                            if (!isExpired) {
                              setState(() {
                                _discountAmount = amount;
                                _discountMessage = "Mã giảm giá hợp lệ!";
                              });

                              try {
                                var userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(authProvider.userId)
                                    .get();

                                if (userDoc.exists) {
                                  var usedCodes = List<String>.from(userDoc['usedDiscountCodes'] ?? []);
                                  if (!usedCodes.contains(discountCode)) {
                                    usedCodes.add(discountCode);
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(authProvider.userId)
                                        .update({'usedDiscountCodes': usedCodes});
                                  }
                                }

                                var snapshot = await FirebaseFirestore.instance
                                    .collection('discountCodes')
                                    .get();

                                for (var doc in snapshot.docs) {
                                  var list = doc['discountCodes'] as List<dynamic>;

                                  for (var i = 0; i < list.length; i++) {
                                    if (list[i]['code'] == discountCode) {
                                      list[i]['isUsed'] = true;
                                      await FirebaseFirestore.instance
                                          .collection('discountCodes')
                                          .doc(doc.id)
                                          .update({'discountCodes': list});
                                      break;
                                    }
                                  }
                                }
                              } catch (e) {
                                print("Lỗi cập nhật mã giảm giá: $e");
                              }
                            } else {
                              setState(() {
                                _discountMessage = "Mã giảm giá không hợp lệ hoặc đã hết hạn!";
                              });
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],

            if (_discountMessage != null) ...[
              SizedBox(height: 8),
              Text(
                _discountMessage!,
                style: TextStyle(
                  color: _discountMessage!.contains("không hợp lệ")
                      ? Colors.red
                      : Colors.green,
                  fontSize: 16,
                ),
              ),
            ],

            SizedBox(height: 24),
            Text("Tổng tiền: ${currencyFormat.format(cartProvider.totalPrice)}",
                style: TextStyle(fontSize: 18, color: Colors.teal[700])),
            if (_discountAmount > 0)
              Text("Giảm giá: ${currencyFormat.format(_discountAmount)}",
                  style: TextStyle(fontSize: 18, color: Colors.red)),
            SizedBox(height: 8),
            Text(
              "Tổng cộng: ${currencyFormat.format(cartProvider.totalPrice - _discountAmount)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[800]),
            ),

            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.check_circle_outline),
                label: Text("Xác nhận Đặt Hàng", style: TextStyle(fontSize: 16)),
                onPressed: () async {
                  await placeOrder(context, authProvider, cartProvider, cartItems, _discountAmount, _selectedDiscountCode);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(value, style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> placeOrder(
    BuildContext context,
    AuthProvider authProvider,
    CartProvider cartProvider,
    Map<String, dynamic> cartItems,
    double discountAmount,
    String discountCode,
  ) async {
    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String orderCode = "ORDER_$timestamp";
      String userCode = "USER_${authProvider.userId ?? 'UNKNOWN'}";

      double finalTotal = cartProvider.totalPrice - discountAmount;
      if (finalTotal < 0) finalTotal = 0;

      // Debug log
      print("DEBUG: Wallet balance = ${authProvider.walletBalance}, Final total = $finalTotal");

      // Nếu chọn thanh toán bằng ví, kiểm tra số dư và trừ tiền
      if (_selectedPaymentMethod == "Ví của tôi") {
        if (authProvider.walletBalance < finalTotal) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ví không đủ tiền để thanh toán!")),
          );
          return; // Dừng đặt hàng
        } else {
          // Trừ tiền trong ví và cập nhật Firestore
          double newBalance = authProvider.walletBalance - finalTotal;
          await authProvider.updateWalletBalance(newBalance);
        }
      }

      final orderData = {
        'orderCode': orderCode,
        'userCode': userCode,
        'userId': authProvider.userId,
        'fullName': authProvider.fullName,
        'email': authProvider.email,
        'phoneNumber': authProvider.phoneNumber,
        'address': authProvider.address,
        'totalAmount': finalTotal,
        'paymentMethod': _selectedPaymentMethod,
        'items': cartItems.values.map((item) => {
          'id': item.id,
          'title': item.title,
          'price': item.price,
          'quantity': item.quantity,
          'imageUrl': item.imageUrl,
          'usedDiscount': discountCode.isNotEmpty,
        }).toList(),
        'discountCode': discountCode,
        'discountAmount': discountAmount,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);
      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đặt hàng thành công! Mã đơn hàng: $orderCode")),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đặt hàng thất bại: $e")),
      );
    }
  }
}
