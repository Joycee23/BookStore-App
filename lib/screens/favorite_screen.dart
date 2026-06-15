import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/book_provider.dart';
import 'package:book_app/widgets/book_item.dart';
import '../utils/app_theme.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoriteBooks = Provider.of<BookProvider>(context).favoriteBooks;

    return Scaffold(
      appBar: AppBar(title: const Text("Yêu thích")),
      body: favoriteBooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCardLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.favorite_border_rounded, size: 48, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Chưa có sách yêu thích",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Nhấn ❤️ để lưu sách bạn thích!",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoriteBooks.length,
              itemBuilder: (context, index) {
                final book = favoriteBooks[index];
                return BookItem(
                  bookId: book.id,
                  title: book.title,
                  author: book.author,
                  imageUrl: book.imageUrl,
                );
              },
            ),
    );
  }
}
