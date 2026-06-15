import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/api_client.dart';
import '../providers/auth_provider.dart';
import 'add_edit_product_screen.dart';
import '../screens/login_screen.dart';
import 'return_requests_screen.dart';
import 'admin_top_selling_screen.dart';
import '../utils/app_theme.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const ProductManagementPage(),
    const ReturnRequestsScreen(),
    const AdminTopSellingScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final titles = ['Quản lý sản phẩm', 'Đơn trả hàng', 'Bán chạy'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductScreen()));
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textMuted),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
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
                _buildNavItem(0, Icons.inventory_2_rounded, "Sản phẩm"),
                _buildNavItem(1, Icons.assignment_return_rounded, "Trả hàng"),
                _buildNavItem(2, Icons.bar_chart_rounded, "Bán chạy"),
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
              Text(label, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================
// Product Management Page
// =============================
class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  String? _selectedCategory = 'Tất cả';
  List<String> _categories = ['Tất cả'];
  bool _isLoading = true;
  List<dynamic> _allBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final List<dynamic> books = await ApiClient.get('/books');
      
      final Set<String> categorySet = {};
      for (var book in books) {
        final cat = book['category'];
        if (cat != null && cat.toString().trim().isNotEmpty) {
          categorySet.add(cat.toString().trim());
        }
      }
      
      if (mounted) {
        setState(() {
          _allBooks = books;
          _categories = ['Tất cả', ...categorySet.toList()];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> displayedBooks = _allBooks;
    if (_selectedCategory != null && _selectedCategory != 'Tất cả') {
      displayedBooks = _allBooks.where((b) => b['category'] == _selectedCategory).toList();
    }

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: AppTheme.bgCard,
          child: Row(
            children: [
              const Icon(Icons.filter_list_rounded, color: AppTheme.textMuted, size: 20),
              const SizedBox(width: 12),
              const Text("Thể loại:", style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Expanded(
                child: _isLoading
                    ? const LinearProgressIndicator(color: AppTheme.primary)
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            dropdownColor: AppTheme.bgCardLight,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                            items: _categories
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        // Book list
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : displayedBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.inventory_2_outlined, color: AppTheme.textMuted, size: 40)),
                        const SizedBox(height: 16),
                        const Text("Chưa có sản phẩm nào", style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedBooks.length,
                    itemBuilder: (context, index) {
                      final data = displayedBooks[index] as Map<String, dynamic>;
                      final imageUrl = data['imageUrl'] as String?;
                      final String docId = data['id'].toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: AppTheme.radiusMd,
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: (imageUrl != null && imageUrl.isNotEmpty)
                                  ? Image.network(imageUrl, width: 52, height: 64, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 52, height: 64, color: AppTheme.bgCardLight, child: const Icon(Icons.book, color: AppTheme.textMuted)))
                                  : Container(width: 52, height: 64, color: AppTheme.bgCardLight, child: const Icon(Icons.book, color: AppTheme.textMuted)),
                            ),
                            title: Text(
                              data['title'] ?? 'Không có tên',
                              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "${data['price']?.toString() ?? 'N/A'} ₫",
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                            iconColor: AppTheme.textMuted,
                            collapsedIconColor: AppTheme.textMuted,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(color: Colors.white10),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['description'] ?? 'Không có mô tả',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _buildAdminBtn(
                                          icon: Icons.edit_rounded,
                                          label: "Sửa",
                                          color: Colors.orangeAccent,
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (_) => AddEditProductScreen(productId: docId, productData: data),
                                            )).then((_) => _fetchBooks());
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        _buildAdminBtn(
                                          icon: Icons.delete_rounded,
                                          label: "Xoá",
                                          color: Colors.redAccent,
                                          onTap: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                backgroundColor: AppTheme.bgCard,
                                                title: const Text("Xác nhận xoá", style: TextStyle(color: AppTheme.textPrimary)),
                                                content: Text("Bạn chắc chắn muốn xoá \"${data['title']}\"?", style: const TextStyle(color: AppTheme.textSecondary)),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Huỷ")),
                                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xoá", style: TextStyle(color: Colors.redAccent))),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              try {
                                                await ApiClient.delete('/books/$docId');
                                                _fetchBooks();
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: const Text("Đã xoá sản phẩm"), backgroundColor: AppTheme.bgCardLight,
                                                        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                                  );
                                                }
                                              } catch(e) {
                                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildAdminBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
