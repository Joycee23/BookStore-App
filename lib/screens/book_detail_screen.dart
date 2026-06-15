import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final double discountedPrice = book.discountedPrice;
    final bool isDiscounted = book.isDiscounted;
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // === Hero Image ===
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background blur
                  book.imageUrl.startsWith('http')
                      ? Image.network(book.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppTheme.bgCard))
                      : Image.asset(book.imageUrl, fit: BoxFit.cover),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.bgDark.withOpacity(0.3),
                          AppTheme.bgDark.withOpacity(0.85),
                          AppTheme.bgDark,
                        ],
                        stops: const [0.0, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                  // Book cover centered with 3D shadow
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(10, 15)),
                          BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 40, spreadRadius: 2),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: book.imageUrl.startsWith('http')
                            ? Image.network(book.imageUrl, height: 240, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 240, width: 160, color: AppTheme.bgCard,
                                  child: const Icon(Icons.book_rounded, color: AppTheme.textMuted, size: 50),
                                ))
                            : Image.asset(book.imageUrl, height: 240, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // === Content ===
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'bởi ${book.author}',
                    style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  // Price & Discount
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDiscounted) ...[
                              Text(
                                formatCurrency.format(discountedPrice),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatCurrency.format(book.price),
                                style: const TextStyle(fontSize: 16, color: AppTheme.textMuted, decoration: TextDecoration.lineThrough),
                              ),
                            ] else ...[
                              Text(
                                formatCurrency.format(book.price),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary),
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        if (isDiscounted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFF3CAC), Color(0xFFFF6B35)]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '-${book.discountPercent?.toStringAsFixed(0)}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats row
                  Row(
                    children: [
                      _buildStatChip(Icons.shopping_bag_outlined, '${book.sold} đã bán'),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.category_outlined, book.category),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Description
                  const Text('Mô tả', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Text(
                    book.description,
                    style: const TextStyle(fontSize: 15, height: 1.7, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      // === Floating Add to Cart ===
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Giá', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  Text(
                    formatCurrency.format(isDiscounted ? discountedPrice : book.price),
                    style: const TextStyle(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.radiusMd,
                  boxShadow: AppTheme.glowShadow(AppTheme.primary),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                  ),
                  onPressed: () {
                    final priceToAdd = isDiscounted ? discountedPrice : book.price;
                    final userId = authProvider.userId ?? '';
                    cartProvider.addItem(userId, book.id, book.title, priceToAdd, book.imageUrl);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${book.title} đã thêm vào giỏ!'),
                        backgroundColor: AppTheme.bgCardLight,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
                  label: const Text('Thêm vào giỏ', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
