import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:book_app/providers/auth_provider.dart';
import 'package:book_app/utils/api_client.dart';
import 'package:book_app/utils/app_theme.dart';

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
  bool _submitting = false;

  File? _selectedImage;

  final String cloudName = "dp5vpjeve";
  final String uploadPreset = "return_requests";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.fullName;
    _phoneController.text = authProvider.phoneNumber;
    _addressController.text = authProvider.address;

    await _loadCartProducts(authProvider.userId!);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadCartProducts(String userId) async {
    try {
      final List<dynamic> orders = await ApiClient.get('/orders?userId=$userId');

      List<String> allTitles = [];
      for (var order in orders) {
        if (order['items'] != null) {
          for (var item in order['items']) {
            allTitles.add(item['book']['title']);
          }
        }
      }

      final unique = allTitles.toSet().toList();
      if (mounted) {
        setState(() {
          productTitles = unique;
          selectedProduct = unique.isNotEmpty ? unique[0] : null;
        });
      }
    } catch (e) {
      print("Lỗi lấy sản phẩm: $e");
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final respData = await http.Response.fromStream(response);
      return json.decode(respData.body)['secure_url'];
    }
    return null;
  }

  Future<void> _submitReturnInfo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(_selectedImage!);
        if (imageUrl == null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không thể upload ảnh")));
          setState(() => _submitting = false);
          return;
        }
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      if (userId == null) return;

      final List<dynamic> orders = await ApiClient.get('/orders?userId=$userId');

      int? matchedOrderCode;
      for (var order in orders) {
        if (order['items'] == null) continue;
        for (var item in order['items']) {
          if (item['book']['title'] == selectedProduct) {
            matchedOrderCode = order['orderCode'];
            break;
          }
        }
        if (matchedOrderCode != null) break;
      }

      if (matchedOrderCode == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không tìm thấy đơn hàng phù hợp")));
        setState(() => _submitting = false);
        return;
      }

      await ApiClient.post('/return_requests', {
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "product": selectedProduct ?? "",
        "address": _addressController.text.trim(),
        "reason": _reasonController.text.trim(),
        "imageUrl": imageUrl ?? "",
        "userId": userId,
        "orderCode": matchedOrderCode,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Yêu cầu trả hàng đã được gửi!"),
            backgroundColor: AppTheme.bgCardLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _submitting = false);
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
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Yêu cầu trả hàng")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: AppTheme.radiusMd,
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.assignment_return_rounded, color: Colors.orangeAccent, size: 26),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Điền thông tin trả hàng", style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text("Chúng tôi sẽ liên hệ bạn trong 24h", style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildLabel("Tên khách hàng"),
              _buildTextField(_nameController, "Nhập họ và tên", Icons.person_rounded, TextInputType.name),
              const SizedBox(height: 20),
              _buildLabel("Số điện thoại"),
              _buildTextField(_phoneController, "Nhập số điện thoại", Icons.phone_rounded, TextInputType.phone),
              const SizedBox(height: 20),
              _buildLabel("Sản phẩm muốn trả"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight,
                  borderRadius: AppTheme.radiusMd,
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedProduct,
                    isExpanded: true,
                    dropdownColor: AppTheme.bgCardLight,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                    hint: const Text("Chọn sản phẩm", style: TextStyle(color: AppTheme.textMuted)),
                    items: productTitles
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedProduct = val),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel("Địa chỉ nhận lại hàng"),
              _buildTextField(_addressController, "Nhập địa chỉ", Icons.location_on_rounded, TextInputType.streetAddress),
              const SizedBox(height: 20),
              _buildLabel("Lý do trả hàng"),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight,
                  borderRadius: AppTheme.radiusMd,
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: TextFormField(
                  controller: _reasonController,
                  maxLines: 4,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                  validator: (val) => val!.isEmpty ? "Vui lòng nhập lý do" : null,
                  decoration: const InputDecoration(
                    hintText: "Mô tả chi tiết lý do trả hàng...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, right: 12),
                      child: Icon(Icons.edit_note_rounded, color: AppTheme.textMuted, size: 22),
                    ),
                    prefixIconConstraints: BoxConstraints(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel("Ảnh sản phẩm (tuỳ chọn)"),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardLight,
                    borderRadius: AppTheme.radiusMd,
                    border: Border.all(
                      color: _selectedImage != null ? AppTheme.primary : Colors.white.withOpacity(0.06),
                      style: _selectedImage != null ? BorderStyle.solid : BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: AppTheme.radiusMd,
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8, right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_rounded, color: AppTheme.textMuted, size: 36),
                            const SizedBox(height: 8),
                            const Text("Nhấn để chọn ảnh", style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: AppTheme.radiusMd,
                    boxShadow: AppTheme.glowShadow(AppTheme.primary),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                    ),
                    onPressed: _submitting ? null : _submitReturnInfo,
                    child: _submitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Gửi yêu cầu trả hàng", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, TextInputType type) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        validator: (val) => val!.isEmpty ? "Không được để trống" : null,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 22),
        ),
      ),
    );
  }
}
