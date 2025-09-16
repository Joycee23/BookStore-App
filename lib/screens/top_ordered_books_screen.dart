import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopOrderedBooksScreen extends StatelessWidget {
  TopOrderedBooksScreen({Key? key}) : super(key: key);

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sách được đặt nhiều nhất")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có đơn hàng nào."));
          }

          // Xử lý dữ liệu
          Map<String, Map<String, dynamic>> bookOrderMap = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data.containsKey('items')) {
              List items = data['items'];

              for (var item in items) {
                String title = item['title'] ?? 'Không tên';
                String imageUrl = item['imageUrl'] ?? '';
                int price = (item['price'] ?? 0).toInt();
                int quantity = (item['quantity'] ?? 1).toInt();

                if (bookOrderMap.containsKey(title)) {
                  bookOrderMap[title]!['quantity'] += quantity;
                } else {
                  bookOrderMap[title] = {
                    'imageUrl': imageUrl,
                    'price': price,
                    'quantity': quantity,
                  };
                }
              }
            }
          }

          // Sắp xếp theo số lượng giảm dần
          var sortedEntries = bookOrderMap.entries.toList()
            ..sort((a, b) => b.value['quantity'].compareTo(a.value['quantity']));
          var sortedMap = Map.fromEntries(sortedEntries);

          return ListView.builder(
            itemCount: sortedMap.length,
            itemBuilder: (context, index) {
              String title = sortedMap.keys.elementAt(index);
              final data = sortedMap[title]!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: data['imageUrl'] != ''
                        ? Image.network(
                            data['imageUrl'],
                            width: 60,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 60),
                          )
                        : const Icon(Icons.book, size: 60),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Giá: ${currencyFormatter.format(data['price'])}\nSố lượng đặt: ${data['quantity']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
