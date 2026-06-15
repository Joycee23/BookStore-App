import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/book_provider.dart';
import 'package:book_app/screens/book/favorite_screen.dart';
import 'package:book_app/screens/order/cart_screen.dart';
import 'package:book_app/screens/profile/profile_screen.dart';
import 'package:book_app/screens/book/category_books_screen.dart';
import 'package:book_app/widgets/book_item.dart';
import 'package:book_app/screens/book/book_detail_screen.dart';
import 'package:book_app/screens/book/top_ordered_books_screen.dart';
import 'package:book_app/utils/app_theme.dart';

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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, "Trang chủ"),
                _buildNavItem(1, Icons.favorite_rounded, "Yêu thích"),
                _buildNavItem(2, Icons.shopping_bag_rounded, "Giỏ hàng"),
                _buildNavItem(3, Icons.star_rounded, "Bán chạy"),
                _buildNavItem(4, Icons.person_rounded, "Cá nhân"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textMuted, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fetchBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    try {
      await Provider.of<BookProvider>(context, listen: false).fetchBooks();
      await Provider.of<BookProvider>(context, listen: false).fetchBestSellingBooks();
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = "Lỗi tải sách. Vui lòng thử lại!");
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final books = bookProvider.books;
    final categories = bookProvider.categories;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 50, height: 50,
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Đang tải sách...", style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchBooks, child: const Text("Thử lại")),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // === Header ===
                    SliverToBoxAdapter(
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Xin chào! 👋",
                                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Khám phá sách hôm nay",
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Search Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCardLight,
                                  borderRadius: AppTheme.radiusMd,
                                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: "Tìm kiếm sách, tác giả...",
                                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                                            onPressed: () {
                                              _searchController.clear();
                                              bookProvider.searchBooks('');
                                            },
                                          )
                                        : null,
                                  ),
                                  onChanged: (query) => bookProvider.searchBooks(query),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // === Categories ===
                    ...categories.map((category) {
                      final categoryBooks = books.where((book) => book.category == category).toList();
                      if (categoryBooks.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                      return SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => CategoryBooksScreen(category: category),
                                      ));
                                    },
                                    child: const Text(
                                      "Xem tất cả →",
                                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: categoryBooks.length,
                                itemBuilder: (context, index) {
                                  final book = categoryBooks[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
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
                        ),
                      );
                    }).toList(),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
    );
  }
}
