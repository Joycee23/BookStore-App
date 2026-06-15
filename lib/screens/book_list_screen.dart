import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_item.dart';
import '../utils/app_theme.dart';

class BookListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final books = Provider.of<BookProvider>(context).books;

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách sách")),
      body: books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(30)),
                    child: const Icon(Icons.menu_book_rounded, size: 48, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),
                  const Text("Chưa có sách nào", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
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
              itemCount: books.length,
              itemBuilder: (context, index) => BookItem(
                bookId: books[index].id,
                title: books[index].title,
                author: books[index].author,
                imageUrl: books[index].imageUrl,
              ),
            ),
    );
  }
}
