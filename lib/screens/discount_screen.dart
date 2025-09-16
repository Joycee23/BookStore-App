import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ✅ Dùng để định dạng ngày

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({Key? key}) : super(key: key);

  @override
  _DiscountScreenState createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  List<Map<String, dynamic>> _discountCodes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDiscountCodes();
  }

  // Hàm tải mã giảm giá theo UID người dùng
  Future<void> _loadDiscountCodes() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('Chưa đăng nhập.');
        return;
      }

      String uid = currentUser.uid;
      // Truy vấn mã giảm giá của người dùng dựa vào UID làm document ID
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('discountCodes')
          .doc(uid) // Dùng UID làm doc ID
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> discountCodes = List<Map<String, dynamic>>.from(data['discountCodes'] ?? []);

        setState(() {
          _discountCodes = discountCodes;
        });
      }
    } catch (e) {
      print('Lỗi khi tải mã giảm giá: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mã giảm giá của tôi"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _discountCodes.isEmpty
              ? const Center(child: Text("Bạn chưa có mã giảm giá nào!"))
              : ListView.builder(
                  itemCount: _discountCodes.length,
                  itemBuilder: (context, index) {
                    var discount = _discountCodes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.card_giftcard,
                          color: Colors.blueAccent,
                        ),
                        title: Text('Mã: ${discount['code']}'),
                        subtitle: Text(
                            'Giảm ${discount['amount']} VND - HSD: ${_formatDate(discount['expiryDate'])}'),
                        trailing: discount['isUsed']
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.cancel, color: Colors.red),
                        onTap: () {
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
