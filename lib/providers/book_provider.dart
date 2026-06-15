import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  List<Book> _bestSellingBooks = [];
  final Set<String> _favoriteBookIds = {}; 

  List<Book> get books => List.unmodifiable(_filteredBooks.isEmpty ? _books : _filteredBooks);
  List<Book> get bestSellingBooks => _bestSellingBooks; 
  List<Book> get favoriteBooks => _books.where((book) => _favoriteBookIds.contains(book.id)).toList();
  List<String> get categories => _books.map((book) => book.category).toSet().toList();

  String get _apiUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/api/books'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _books = data.map((json) => Book.fromJson(json)).toList();
        _filteredBooks = List.from(_books);
        notifyListeners();
      } else {
        throw Exception('Failed to load books');
      }
    } catch (error) {
      print("Lỗi tải sách từ Backend: $error");
      throw error;
    }
  }

  Future<void> fetchBestSellingBooks() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/api/books/bestsellers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _bestSellingBooks = data.map((json) => Book.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load best sellers');
      }
    } catch (error) {
      print("Lỗi tải sách bán chạy từ Backend: $error");
      throw error;
    }
  }

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

  Book findById(String id) {
    return _books.firstWhere((book) => book.id == id);
  }

  bool isFavorite(String bookId) {
    return _favoriteBookIds.contains(bookId);
  }

  void toggleFavorite(String bookId) {
    if (_favoriteBookIds.contains(bookId)) {
      _favoriteBookIds.remove(bookId);
    } else {
      _favoriteBookIds.add(bookId);
    }
    notifyListeners();
  }
}
