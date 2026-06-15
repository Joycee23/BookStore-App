import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/auth_provider.dart';
import '../utils/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fullNameController = TextEditingController(text: authProvider.fullName);
    _emailController = TextEditingController(text: authProvider.email ?? '');
    _phoneController = TextEditingController(text: authProvider.phoneNumber);
    _addressController = TextEditingController(text: authProvider.address);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      await Provider.of<AuthProvider>(context, listen: false).updateUserInfo(
        email: _emailController.text,
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
      );

      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Cập nhật thông tin thành công!"),
          backgroundColor: AppTheme.bgCardLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowShadow(AppTheme.primary),
                      ),
                      child: Center(
                        child: Text(
                          (_fullNameController.text.isNotEmpty ? _fullNameController.text[0] : "U").toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.bgCardLight, shape: BoxShape.circle, border: Border.all(color: AppTheme.bgCard, width: 2)),
                        child: const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildLabel("Email"),
              _buildTextField(_emailController, "Email không thể thay đổi", Icons.email_rounded, TextInputType.emailAddress, readOnly: true),
              const SizedBox(height: 20),
              _buildLabel("Họ và Tên"),
              _buildTextField(_fullNameController, "Vd: Nguyễn Văn A", Icons.person_rounded, TextInputType.name),
              const SizedBox(height: 20),
              _buildLabel("Số điện thoại"),
              _buildTextField(_phoneController, "Vd: 0912345678", Icons.phone_rounded, TextInputType.phone),
              const SizedBox(height: 20),
              _buildLabel("Địa chỉ nhận hàng"),
              _buildTextField(_addressController, "Vd: 123 Đường ABC, Quận 1...", Icons.location_on_rounded, TextInputType.streetAddress),
              const SizedBox(height: 48),
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
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Lưu thay đổi", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, TextInputType type, {bool readOnly = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
        style: TextStyle(color: readOnly ? AppTheme.textMuted : AppTheme.textPrimary, fontSize: 16),
        validator: (value) => value!.isEmpty ? "Không được để trống" : null,
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
