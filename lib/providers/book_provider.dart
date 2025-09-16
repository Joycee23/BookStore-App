import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Book> _books = [];
  List<Book> _filteredBooks = []; // Danh sách sách đã lọc theo tìm kiếm
  List<Book> _bestSellingBooks = []; // Danh sách sách bán chạy
  List<Book> _homeBooks = []; // Danh sách sách từ 'homeBooks'
  final Set<String> _favoriteBookIds = {}; // Lưu danh sách sách yêu thích

  List<Book> get books => List.unmodifiable(_filteredBooks.isEmpty ? _books : _filteredBooks);
  List<Book> get bestSellingBooks => _bestSellingBooks; // Getter cho sách bán chạy
  List<Book> get favoriteBooks => _books.where((book) => _favoriteBookIds.contains(book.id)).toList();
  List<String> get categories => _books.map((book) => book.category).toSet().toList();
  List<Book> get homeBooks => _homeBooks; // Getter cho sách từ 'homeBooks'

  // Phương thức sao chép sách từ collection 'books' vào 'homeBooks' và thêm trường isVisible
  Future<void> copyBooksToHomeBooks() async {
    try {
      final querySnapshot = await _firestore.collection('books').get();

      for (var doc in querySnapshot.docs) {
        final bookData = doc.data();

        // Sao chép sách vào collection 'homeBooks' và thêm trường isVisible
        await _firestore.collection('homeBooks').doc(doc.id).set({
          'title': bookData['title'],
          'author': bookData['author'],
          'price': bookData['price'],
          'imageUrl': bookData['imageUrl'],
          'category': bookData['category'],
          'description': bookData['description'],
          'discountPercent': bookData['discountPercent'] ?? 0.0,
          'discountEndDate': bookData['discountEndDate'],
          'sold': bookData['sold'] ?? 0,
          'isVisible': true, // Thêm trường isVisible để kiểm soát việc hiển thị sách
        });
      }
      print("Sao chép sách thành công!");
    } catch (error) {
      print("Lỗi sao chép sách: $error");
    }
  }

  // Phương thức tải sách từ collection 'homeBooks'
  Future<void> fetchHomeBooks() async {
    try {
      final querySnapshot = await _firestore.collection('homeBooks').get();
      _homeBooks = querySnapshot.docs.map((doc) {
        return Book(
          id: doc.id,
          title: doc['title'],
          author: doc['author'],
          price: doc['price'].toDouble(),
          imageUrl: doc['imageUrl'],
          category: doc['category'],
          description: doc['description'],
          discountPercent: doc['discountPercent']?.toDouble(),
          discountEndDate: doc['discountEndDate'] != null
              ? (doc['discountEndDate'] as Timestamp).toDate()
              : null,
          sold: doc['sold'] ?? 0,
          isVisible: doc['isVisible'] ?? true, // Lấy trường isVisible từ Firestore
        );
      }).toList();
      notifyListeners();
    } catch (error) {
      print("Lỗi tải sách từ 'homeBooks': $error");
      throw error;
    }
  }

  // Phương thức tải sách từ Firestore (books)
  Future<void> fetchBooks() async {
    try {
      final querySnapshot = await _firestore.collection('books').get();
      _books = querySnapshot.docs.map((doc) {
        return Book(
          id: doc.id,
          title: doc['title'],
          author: doc['author'],
          price: doc['price'].toDouble(),
          imageUrl: doc['imageUrl'],
          category: doc['category'],
          description: doc['description'],
        );
      }).toList();
      _filteredBooks = List.from(_books); // Khởi tạo danh sách lọc
      notifyListeners();
    } catch (error) {
      print("Lỗi tải sách từ Firestore: $error");
      throw error;
    }
  }

  // Phương thức tải sách bán chạy từ Firestore
  Future<void> fetchBestSellingBooks() async {
    try {
      final querySnapshot = await _firestore.collection('books').get();
      
      // Lọc sách bán chạy (sold > 100)
      _bestSellingBooks = querySnapshot.docs.map((doc) {
        final bookData = doc.data();
        return Book(
          id: doc.id,
          title: bookData['title'],
          author: bookData['author'],
          price: bookData['price'].toDouble(),
          imageUrl: bookData['imageUrl'],
          category: bookData['category'],
          description: bookData['description'],
          sold: bookData.containsKey('sold') ? bookData['sold'] : 0, // Kiểm tra sự tồn tại của 'sold'
        );
      }).where((book) => book.sold > 100).toList(); // Lọc sách bán chạy

      notifyListeners();
    } catch (error) {
      print("Lỗi tải sách bán chạy từ Firestore: $error");
      throw error;
    }
  }

  // Phương thức tìm sách theo tên hoặc tác giả
  void searchBooks(String query) {
    if (query.isEmpty) {
      _filteredBooks = List.from(_books);
    } else {
      _filteredBooks = _books.where((book) =>
        book.title.toLowerCase().contains(query.toLowerCase()) ||
        book.author.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }

  // Tìm sách theo ID
  Book findById(String id) {
    return _books.firstWhere((book) => book.id == id);
  }

  // Kiểm tra sách có phải yêu thích không
  bool isFavorite(String bookId) {
    return _favoriteBookIds.contains(bookId);
  }

  // Thêm hoặc bỏ yêu thích
  void toggleFavorite(String bookId) {
    if (_favoriteBookIds.contains(bookId)) {
      _favoriteBookIds.remove(bookId);
    } else {
      _favoriteBookIds.add(bookId);
    }
    notifyListeners();
  }
}
