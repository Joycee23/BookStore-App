import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as my_auth;
import '../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_acceptTerms) {
      _showSnackBar("Bạn phải chấp nhận điều khoản và điều kiện!");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Mật khẩu không khớp!");
      return;
    }
    setState(() => _isLoading = true);
    final auth = Provider.of<my_auth.AuthProvider>(context, listen: false);
    String message = await auth.register(_emailController.text, _passwordController.text, context);
    setState(() => _isLoading = false);
    _showSnackBar(message);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.bgCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Floating orb top-right
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.secondary.withOpacity(0.3), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.2), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.bgCardLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    const Text(
                      "Tạo tài khoản",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Đăng ký để bắt đầu hành trình đọc sách",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                    ),
                    const SizedBox(height: 40),
                    _buildLabel("Email"),
                    const SizedBox(height: 8),
                    _buildField(_emailController, "your@email.com", Icons.email_outlined),
                    const SizedBox(height: 20),
                    _buildLabel("Mật khẩu"),
                    const SizedBox(height: 8),
                    _buildField(_passwordController, "••••••••", Icons.lock_outline_rounded,
                        isPassword: true, obscure: _obscurePassword,
                        toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword)),
                    const SizedBox(height: 20),
                    _buildLabel("Xác nhận mật khẩu"),
                    const SizedBox(height: 8),
                    _buildField(_confirmPasswordController, "••••••••", Icons.lock_outline_rounded,
                        isPassword: true, obscure: _obscureConfirm,
                        toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                    const SizedBox(height: 16),
                    // Terms
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: _acceptTerms ? AppTheme.primaryGradient : null,
                              color: _acceptTerms ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                              border: _acceptTerms ? null : Border.all(color: AppTheme.textMuted, width: 2),
                            ),
                            child: _acceptTerms
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              text: "Tôi đồng ý với ",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: "Điều khoản & Điều kiện",
                                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                          : Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius: AppTheme.radiusMd,
                                boxShadow: AppTheme.glowShadow(AppTheme.secondary),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                                ),
                                onPressed: _register,
                                child: const Text("Đăng ký", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: "Đã có tài khoản? ",
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                            children: [
                              TextSpan(
                                text: "Đăng nhập",
                                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600));
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false, bool obscure = false, VoidCallback? toggleObscure}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppTheme.textMuted, size: 22),
                  onPressed: toggleObscure,
                )
              : null,
        ),
      ),
    );
  }
}
