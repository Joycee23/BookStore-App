import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';  // Import thêm thư viện uuid

class ReturnInfoScreen extends StatefulWidget {
  const ReturnInfoScreen({Key? key}) : super(key: key);

  @override
  State<ReturnInfoScreen> createState() => _ReturnInfoScreenState();
}

class _ReturnInfoScreenState extends State<ReturnInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  List<String> productTitles = [];
  String? selectedProduct;
  bool isLoading = true;

  File? _selectedImage;
  String? _uploadedImageUrl;

  final String cloudName = "dp5vpjeve"; // Thay bằng tên cloudinary của bạn
  final String uploadPreset = "return_requests"; // Thay bằng preset upload của bạn

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUserProfile(),
      _loadCartProducts(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _nameController.text = data['fullName'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _addressController.text = data['address'] ?? '';
        }
      }
    } catch (e) {
      print("Lỗi lấy thông tin user profile: $e");
    }
  }

  Future<void> _loadCartProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userEmail = user.email;
      if (userEmail == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: userEmail)
          .get();

      List<String> allProductTitles = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          List items = data['items'];
          for (var item in items) {
            bool usedDiscount = item['usedDiscount'] == true;
            if (!usedDiscount) {
              allProductTitles.add(item['title']);
            }
          }
        }
      }

      final uniqueProductTitles = allProductTitles.toSet().toList();

      setState(() {
        productTitles = uniqueProductTitles;
        selectedProduct = productTitles.isNotEmpty ? productTitles[0] : null;
      });
    } catch (e) {
      print("Lỗi lấy sản phẩm trong đơn hàng: $e");
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respData = await http.Response.fromStream(response);
      final jsonData = json.decode(respData.body);
      return jsonData['secure_url'];
    } else {
      print("Lỗi khi upload ảnh lên Cloudinary: ${response.statusCode}");
      return null;
    }
  }

  Future<void> _submitReturnInfo() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(_selectedImage!);
        if (imageUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không thể upload ảnh")));
          return;
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chưa đăng nhập")));
        return;
      }

      try {
        final ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('email', isEqualTo: user.email)
            .get();

        if (ordersSnapshot.docs.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không tìm thấy đơn hàng nào với email này")));
          return;
        }

        String? matchedOrderCode;
        String? matchedUserId;

        for (var orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data();

          if (orderData['items'] == null) continue;

          List items = orderData['items'];
          bool foundProduct = false;
          for (var item in items) {
            if (item['title'] == selectedProduct) {
              matchedOrderCode = orderData['orderCode'];
              matchedUserId = orderData['userId'];
              foundProduct = true;
              break;
            }
          }
          if (foundProduct) break;
        }

        if (matchedOrderCode == null || matchedUserId == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không tìm thấy đơn hàng phù hợp với sản phẩm")),
          );
          return;
        }

        // Tạo ID trả hàng mới bằng uuid
        var uuid = Uuid();
        String returnRequestId = uuid.v4();

        // Lưu dữ liệu trả hàng vào Firestore với id là returnRequestId
        await FirebaseFirestore.instance.collection("return_requests").doc(returnRequestId).set({
          "returnRequestId": returnRequestId,
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "product": selectedProduct ?? "",
          "address": _addressController.text.trim(),
          "reason": _reasonController.text.trim(),
          "imageUrl": imageUrl ?? "",
          "timestamp": FieldValue.serverTimestamp(),
          "userId": matchedUserId,
          "orderCode": matchedOrderCode,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thông tin đã được gửi đi")),
        );

        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi gửi thông tin: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin trả hàng"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Tên khách hàng", Icons.person),
                validator: (value) => value!.isEmpty ? "Nhập tên khách hàng" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration("Số điện thoại", Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Nhập số điện thoại" : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Sản phẩm muốn trả", Icons.shopping_bag),
                  value: selectedProduct,
                  items: productTitles
                      .map((title) => DropdownMenuItem(
                            value: title,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value;
                    });
                  },
                  validator: (value) => (value == null || value.isEmpty) ? "Chọn sản phẩm" : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration("Địa chỉ nhận hàng", Icons.home),
                validator: (value) => value!.isEmpty ? "Nhập địa chỉ" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: _inputDecoration("Lý do trả hàng", Icons.comment),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? "Nhập lý do trả hàng" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : const Text("Chưa chọn ảnh"),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Chọn ảnh"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitReturnInfo,
                child: const Text("Gửi thông tin trả hàng"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
