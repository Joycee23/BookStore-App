import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_app/providers/book_provider.dart';
import 'package:book_app/screens/favorite_screen.dart';
import 'package:book_app/screens/cart_screen.dart';
import 'package:book_app/screens/profile_screen.dart';
import 'package:book_app/screens/category_books_screen.dart';
import 'package:book_app/widgets/book_item.dart';
import 'package:book_app/screens/book_detail_screen.dart';
import 'package:book_app/screens/top_ordered_books_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreenContent(),      
    FavoriteScreen(),         
    CartScreen(),             
    TopOrderedBooksScreen(),  
    ProfileScreen(),          
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Yêu thích'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Top Order'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _bannerImages = [];
  int _currentBannerIndex = 0;
  PageController _pageController = PageController();
  Timer? _bannerTimer;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _fetchBannerImages();
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (!mounted || !_pageController.hasClients || _bannerImages.isEmpty) return;

        int nextPage = (_currentBannerIndex + 1) % _bannerImages.length;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        if (!mounted) return;
        setState(() {
          _currentBannerIndex = nextPage;
        });
      });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    try {
      await Provider.of<BookProvider>(context, listen: false).fetchBooks();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Lỗi tải sách. Vui lòng thử lại!";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBannerImages() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('ads').get();
      if (!mounted) return;
      setState(() {
        _bannerImages = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
      });
    } catch (error) {
      print("Lỗi tải ảnh banner: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final books = bookProvider.books;
    final categories = bookProvider.categories;

    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : books.isEmpty
                  ? const Center(child: Text("Không có sách nào!"))
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: "Tìm kiếm sách...",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (query) {
                                      bookProvider.searchBooks(query);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            if (_bannerImages.isNotEmpty)
                              SizedBox(
                                height: 150,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _bannerImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          _bannerImages[index],
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        (loadingProgress.expectedTotalBytes ?? 1)
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            SizedBox(height: 10),
                            ...categories.map((category) {
                              final categoryBooks = books
                                  .where((book) => book.category == category)
                                  .toList();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange),
                                    ),
                                  ),
                                  Container(
                                    height: 250,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categoryBooks.length,
                                      itemBuilder: (context, index) {
                                        final book = categoryBooks[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: BookItem(
                                            key: ValueKey(book.id),
                                            title: book.title,
                                            author: book.author,
                                            imageUrl: book.imageUrl,
                                            bookId: book.id,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
