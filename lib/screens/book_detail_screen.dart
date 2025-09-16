import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import thư viện intl để format giá
import '../models/book.dart';
import '../providers/cart_provider.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    final double discountedPrice = book.discountedPrice;
    final bool isDiscounted = book.isDiscounted;

    // Hàm format giá tiền
    String formatPrice(double price) {
      final formatCurrency = NumberFormat.currency(
        locale: 'vi_VN', // Đặt locale là Việt Nam
        symbol: '₫', // Hiển thị ký hiệu VND
      );
      return formatCurrency.format(price); // Format giá tiền thành VND
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: book.imageUrl.startsWith('http')
                    ? Image.network(
                        book.imageUrl,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/placeholder.jpg',
                                height: 250, fit: BoxFit.cover),
                      )
                    : Image.asset(
                        book.imageUrl,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tác giả: ${book.author}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // ✅ Hiển thị giá giảm hoặc giá gốc
            if (isDiscounted) ...[
              Text(
                'Giá: ${formatPrice(discountedPrice)}', // Hiển thị giá giảm
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 4),
              Text(
                'Giá gốc: ${formatPrice(book.price)}', // Hiển thị giá gốc
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Giảm ${book.discountPercent?.toStringAsFixed(0) ?? 0}%, đến hết: ${book.discountEndDate?.toLocal().toString().substring(0, 10) ?? ''}',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            ] else ...[
              Text(
                'Giá: ${formatPrice(book.price)}', // Hiển thị giá gốc
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],

            const SizedBox(height: 16),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Mô tả:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              book.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final priceToAdd = isDiscounted ? discountedPrice : book.price;
                    cartProvider.addItem(book.id, book.title, priceToAdd, book.imageUrl);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${book.title} đã được thêm vào giỏ hàng!')),
                    );
                  },
                  child: const Text(
                    'Thêm vào giỏ hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
