import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../utils/api_client.dart';

class TopOrderedBooksScreen extends StatefulWidget {
  const TopOrderedBooksScreen({Key? key}) : super(key: key);

  @override
  _TopOrderedBooksScreenState createState() => _TopOrderedBooksScreenState();
}

class _TopOrderedBooksScreenState extends State<TopOrderedBooksScreen> {
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  bool _isLoading = true;
  List<dynamic> _topBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchTopBooks();
  }

  Future<void> _fetchTopBooks() async {
    try {
      final List<dynamic> books = await ApiClient.get('/books?sort=sold');
      setState(() {
        // Lọc những sách đã bán > 0
        _topBooks = books.where((b) => (b['sold'] ?? 0) > 0).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bán chạy nhất")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _topBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(30)),
                        child: const Icon(Icons.star_outline_rounded, size: 48, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 20),
                      const Text("Chưa có sách nào được bán", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _topBooks.length,
                  itemBuilder: (context, index) {
                    final data = _topBooks[index];
                    String title = data['title'] ?? 'Không tên';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: AppTheme.radiusMd,
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: [
                          if (index < 3) BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Rank Badge for top 3
                          if (index < 3)
                            Container(
                              width: 32, height: 32,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                gradient: index == 0 ? AppTheme.primaryGradient : index == 1 ? AppTheme.accentGradient : AppTheme.walletGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                            )
                          else
                            Container(
                              width: 32, height: 32,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(color: AppTheme.bgCardLight, shape: BoxShape.circle),
                              child: Center(child: Text('${index + 1}', style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w800))),
                            ),
                          
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: data['imageUrl'] != '' && data['imageUrl'] != null
                                ? Image.network(data['imageUrl'], width: 50, height: 70, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 50, height: 70, color: AppTheme.bgCardLight, child: const Icon(Icons.book, color: AppTheme.textMuted)))
                                : Container(width: 50, height: 70, color: AppTheme.bgCardLight, child: const Icon(Icons.book, color: AppTheme.textMuted)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(currencyFormatter.format(data['price']), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(6)),
                                      child: Text('Đã bán: ${data['sold']}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
