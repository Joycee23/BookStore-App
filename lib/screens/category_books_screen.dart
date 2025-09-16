import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/book_provider.dart';
import 'package:book_app/widgets/book_item.dart';

class CategoryBooksScreen extends StatelessWidget {
  final String category;

  const CategoryBooksScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final books = Provider.of<BookProvider>(context).books
        .where((book) => book.category == category)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Thể loại: $category")),
      body: books.isEmpty
          ? const Center(child: Text("Không có sách nào!"))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) => BookItem(
                key: ValueKey(books[index].id),
                bookId: books[index].id,
                title: books[index].title,
                author: books[index].author,
                imageUrl: books[index].imageUrl,
              ),
            ),
    );
  }
}
