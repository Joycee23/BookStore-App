import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/book_provider.dart';
import 'package:book_app/widgets/book_item.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoriteBooks = Provider.of<BookProvider>(context).favoriteBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sách Yêu Thích"),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: favoriteBooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Chưa có sách yêu thích!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: favoriteBooks.length,
                itemBuilder: (context, index) {
                  final book = favoriteBooks[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: BookItem(
                      bookId: book.id,
                      title: book.title,
                      author: book.author,
                      imageUrl: book.imageUrl,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
