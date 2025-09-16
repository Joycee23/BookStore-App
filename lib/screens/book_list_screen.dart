import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_item.dart';

class BookListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final books = Provider.of<BookProvider>(context).books;

    return Scaffold(
      appBar: AppBar(title: Text("Danh sách sách")),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) => BookItem(book: books[index]),
      ),
    );
  }
}
