import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReturnRequestDetailScreen extends StatelessWidget {
  final String returnId;

  const ReturnRequestDetailScreen({
    super.key,
    required this.returnId,
  });

  @override
  Widget build(BuildContext context) {
    if (returnId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chi tiết đơn trả"),
          centerTitle: true,
        ),
        body: const Center(child: Text("Mã đơn trả hàng không hợp lệ.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đơn trả"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('return_requests')
            .doc(returnId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Không tìm thấy đơn trả hàng."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Không rõ';
          final phone = data['phone'] ?? 'N/A';
          final address = data['address'] ?? 'Chưa có địa chỉ';
          final product = data['product'] ?? 'Không xác định';
          final reason = data['reason'] ?? 'Không có lý do';
          final status = data['status'] ?? 'Chưa xử lý';
          final timestamp = data['timestamp'] as Timestamp?;
          final formattedDate = timestamp != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate())
              : 'Chưa có thời gian';
          final String? imageUrl = data['imageUrl'];
          final String orderCode = data['orderCode'] ?? 'Không rõ';
          final String userId = data['userId'] ?? '';

          final Color statusColor = status == 'Đã duyệt'
              ? Colors.green
              : (status == 'Đang xử lý' ? Colors.orange : Colors.grey);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                shadowColor: Colors.blueAccent.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image,
                                    size: 80, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      _buildInfoItem(Icons.shopping_bag, "Sản phẩm", product),
                      _buildInfoItem(Icons.person, "Người trả", name),
                      _buildInfoItem(Icons.phone, "Số điện thoại", phone),
                      _buildInfoItem(Icons.location_on, "Địa chỉ", address),
                      _buildInfoItem(Icons.report_problem, "Lý do trả", reason),
                      _buildInfoItem(Icons.receipt, "Mã đơn hàng", orderCode),
                      _buildInfoItem(Icons.account_circle, "Mã người dùng", userId),
                      _buildInfoItem(Icons.access_time, "Thời gian", formattedDate),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          const Text("Trạng thái:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (status == 'Chưa xử lý')
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("Chấp Nhận trả hàng",
                                style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (userId.isEmpty || product.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Dữ liệu người dùng hoặc sản phẩm không hợp lệ')),
                                );
                                return;
                              }

                              final docRef = FirebaseFirestore.instance
                                  .collection('return_requests')
                                  .doc(returnId);

                              try {
                                // Lấy lại dữ liệu đơn trả hàng để đảm bảo đồng bộ
                                final docSnapshot = await docRef.get();
                                if (!docSnapshot.exists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Đơn trả hàng không tồn tại')),
                                  );
                                  return;
                                }

                                // Tìm sách dựa trên tên product
                                final booksQuery = await FirebaseFirestore.instance
                                    .collection('books')
                                    .where('title', isEqualTo: product)
                                    .limit(1)
                                    .get();

                                if (booksQuery.docs.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Không tìm thấy sách phù hợp')),
                                  );
                                  return;
                                }

                                final bookData = booksQuery.docs.first.data();
                                final double productPrice =
                                    (bookData['price'] ?? 0).toDouble();

                                // Lấy ví của userId chính xác
                                final walletRef = FirebaseFirestore.instance
                                    .collection('wallets')
                                    .doc(userId);

                                final walletSnapshot = await walletRef.get();

                                double currentBalance = 0.0;
                                if (walletSnapshot.exists) {
                                  currentBalance =
                                      (walletSnapshot.data()?['balance'] ?? 0)
                                          .toDouble();
                                }

                                // Cộng tiền hoàn trả vào ví
                                await walletRef.set({
                                  'balance': currentBalance + productPrice,
                                }, SetOptions(merge: true));

                                // Cập nhật trạng thái đơn trả hàng thành "Đã duyệt"
                                await docRef.update({'status': 'Đã duyệt'});

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Xử lý trả hàng thành công')),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Lỗi xử lý: ${e.toString()}')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String? value) {
    final displayValue =
        (value == null || value.isEmpty) ? 'Không có dữ liệu' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(displayValue, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
