import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../screens/book_detail_screen.dart';

class BookItem extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final String bookId;

  const BookItem({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final isFavorite = bookProvider.isFavorite(bookId);
    final book = bookProvider.findById(bookId);

    return GestureDetector(
      onTap: () {
        if (book != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book),
            ),
          );
        }
      },
      child: Container(
        width: 140,
        height: 240, // Giới hạn tổng chiều cao item
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh chiếm phần còn lại (ưu tiên co lại nếu thiếu chỗ)
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Image.asset(
                              'assets/images/placeholder_book.png',
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            // Tiêu đề sách
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Tác giả
            Text(
              author,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Icon yêu thích
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                  size: 18,
                ),
                onPressed: () {
                  bookProvider.toggleFavorite(bookId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
