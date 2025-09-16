import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_edit_product_screen.dart';
import '../screens/login_screen.dart';
import 'return_requests_screen.dart';
import 'admin_top_selling_screen.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AppBar _buildAppBar() {
    final titles = ['Quản lý sản phẩm', 'Các đơn trả hàng', 'Sản phẩm bán chạy'];

    int index = _selectedIndex;
    if (index < 0 || index >= _pages.length) {
      index = 0;
    }

    return AppBar(
      title: Text(titles[index]),
      backgroundColor: Colors.blueAccent,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
        if (index == 0)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int index = _selectedIndex;
    if (index < 0 || index >= _pages.length) {
      index = 0;
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: _pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Đơn trả hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Bán chạy',
          ),
        ],
      ),
    );
  }
}

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  String? _selectedCategory = 'Tất cả';
  List<String> _categories = ['Tất cả'];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesFromFirestore();
  }

  Future<void> _fetchCategoriesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('books').get();

      final Set<String> categorySet = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'];
        if (category != null && category.toString().trim().isNotEmpty) {
          categorySet.add(category.toString().trim());
        }
      }

      setState(() {
        _categories = ['Tất cả', ...categorySet.toList()];
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      debugPrint("Lỗi khi lấy thể loại: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('books');

    if (_selectedCategory != null &&
        _selectedCategory != 'Tất cả' &&
        _selectedCategory!.isNotEmpty) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Text(
                'Chọn thể loại:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              if (_isLoadingCategories)
                const CircularProgressIndicator()
              else
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Lỗi khi tải dữ liệu"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text("Chưa có sản phẩm nào."));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final title = data['title'] ?? 'Không có tên';
                  final price = data['price']?.toString() ?? 'N/A';
                  final imageUrl = data['imageUrl'];
                  final description = data['description'] ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpansionTile(
                      leading: (imageUrl != null && imageUrl.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl,
                                  width: 50, height: 50, fit: BoxFit.cover),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.white),
                            ),
                      title: Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Giá: $price đ",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.green)),
                              const SizedBox(height: 8),
                              Text("Mô tả: $description",
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    label: const Text("Sửa"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddEditProductScreen(
                                            productId: doc.id,
                                            productData: data,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    label: const Text("Xoá",
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('books')
                                          .doc(doc.id)
                                          .delete();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text("Đã xoá sản phẩm")),
                                      );
                                    },
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
              );
            },
          ),
        ),
      ],
    );
  }
}
