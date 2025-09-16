import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm dòng này

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

  bool _isBestseller = false;

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      _titleController.text = widget.productData!['title'] ?? '';
      final price = widget.productData!['price'];
      _priceController.text = price != null ? price.toString() : '';
      _imageUrlController.text = widget.productData!['imageUrl'] ?? '';
      _descriptionController.text = widget.productData!['description'] ?? '';
      _authorController.text = widget.productData!['author'] ?? '';
      _categoryController.text = widget.productData!['category'] ?? '';
      _isBestseller = widget.productData!['isBestseller'] ?? false;
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final price = double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', ''));

        final product = {
          'title': _titleController.text,
          'price': price ?? 0,
          'imageUrl': _imageUrlController.text,
          'description': _descriptionController.text,
          'author': _authorController.text,
          'category': _categoryController.text,
          'isBestseller': _isBestseller,
        };

        final collection = FirebaseFirestore.instance.collection('books');

        if (widget.productId != null) {
          await collection.doc(widget.productId).update(product);
        } else {
          await collection.add(product);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.productId != null ? 'Cập nhật thành công' : 'Thêm mới thành công')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
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

  String formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Tên sản phẩm',
                  validator: _requiredValidator,
                ),
                _buildTextField(
                  controller: _authorController,
                  label: 'Tác giả',
                  validator: _requiredValidator,
                ),
                _buildTextField(
                  controller: _categoryController,
                  label: 'Thể loại',
                  validator: _requiredValidator,
                ),
                _buildTextField(
                  controller: _priceController,
                  label: 'Giá (VND)',
                  keyboardType: TextInputType.number,
                  validator: _priceValidator,
                ),
                _buildTextField(
                  controller: _imageUrlController,
                  label: 'URL ảnh',
                  validator: _requiredValidator,
                ),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Mô tả',
                  maxLines: 3,
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProduct,
                  child: Text(isEditing ? 'Cập nhật' : 'Thêm mới'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    return (value == null || value.isEmpty) ? 'Không được để trống' : null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.isEmpty) return 'Không được để trống';
    if (double.tryParse(value.replaceAll('.', '').replaceAll(',', '')) == null) return 'Giá trị không hợp lệ';
    return null;
  }
}
