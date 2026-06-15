import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/api_client.dart';
class AddEditProductScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? productData;

  const AddEditProductScreen({super.key, this.productId, this.productData});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      _titleController.text = widget.productData!['title'] ?? '';
      _priceController.text = widget.productData!['price']?.toString() ?? '';
      _imageUrlController.text = widget.productData!['imageUrl'] ?? '';
      _descriptionController.text = widget.productData!['description'] ?? '';
      _authorController.text = widget.productData!['author'] ?? '';
      _categoryController.text = widget.productData!['category'] ?? '';
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final price = double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
      final product = {
        'title': _titleController.text.trim(),
        'price': price,
        'imageUrl': _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'author': _authorController.text.trim(),
        'category': _categoryController.text.trim(),
      };

      if (widget.productId != null) {
        await ApiClient.put('/books/${widget.productId}', product);
      } else {
        await ApiClient.post('/books', product);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productId != null ? 'Cập nhật thành công!' : 'Thêm sách thành công!'),
            backgroundColor: AppTheme.bgCardLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Sửa sản phẩm' : 'Thêm sách mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover preview
              if (_imageUrlController.text.isNotEmpty)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    height: 180,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: AppTheme.radiusMd,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(8, 12))],
                    ),
                    child: ClipRRect(
                      borderRadius: AppTheme.radiusMd,
                      child: Image.network(_imageUrlController.text, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppTheme.bgCardLight, child: const Icon(Icons.book, color: AppTheme.textMuted, size: 40))),
                    ),
                  ),
                ),

              _buildLabel("Tên sách"),
              _buildTextField(_titleController, "Vd: Đắc Nhân Tâm", Icons.title_rounded),
              const SizedBox(height: 20),
              _buildLabel("Tác giả"),
              _buildTextField(_authorController, "Vd: Dale Carnegie", Icons.person_rounded),
              const SizedBox(height: 20),
              _buildLabel("Thể loại"),
              _buildTextField(_categoryController, "Vd: Kỹ năng sống", Icons.category_rounded),
              const SizedBox(height: 20),
              _buildLabel("Giá (₫)"),
              _buildTextField(_priceController, "Vd: 95000", Icons.attach_money_rounded, type: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Không được để trống';
                  if (double.tryParse(v.replaceAll('.', '').replaceAll(',', '')) == null) return 'Giá không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel("URL ảnh bìa"),
              _buildTextField(
                _imageUrlController, "https://...", Icons.image_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _buildLabel("Mô tả"),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight,
                  borderRadius: AppTheme.radiusMd,
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: "Nhập mô tả sách...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, right: 12),
                      child: Icon(Icons.description_rounded, color: AppTheme.textMuted, size: 22),
                    ),
                    prefixIconConstraints: BoxConstraints(),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd)),
                    onPressed: _isSaving ? null : _saveProduct,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEditing ? 'Lưu thay đổi' : 'Thêm sách', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
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
        onChanged: onChanged,
        validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
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
