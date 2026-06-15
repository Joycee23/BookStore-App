import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/auth_provider.dart';
import 'package:book_app/utils/app_theme.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      _emailController.text = authProvider.email ?? '';
      _fullNameController.text = authProvider.fullName;
      _phoneController.text = authProvider.phoneNumber;
      _addressController.text = authProvider.address;
    }
  }

  void _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      await Provider.of<AuthProvider>(context, listen: false).updateUserInfo(
        email: _emailController.text,
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
      );

      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hoàn tất hồ sơ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Xin chào!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text("Vui lòng bổ sung thông tin để tiếp tục", style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 40),
              _buildLabel("Email"),
              _buildTextField(_emailController, "Nhập email của bạn", Icons.email_rounded, TextInputType.emailAddress, readOnly: true), // Email thường ko cho sửa
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
                    onPressed: _isLoading ? null : _saveUserInfo,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Lưu thông tin & Tiếp tục", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
