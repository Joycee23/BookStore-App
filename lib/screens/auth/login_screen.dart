import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/auth_provider.dart';
import 'package:book_app/utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? message = await auth.login(_emailController.text, _passwordController.text, context);
    setState(() => _isLoading = false);
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? message = await auth.loginWithGoogle(context);
    setState(() => _isLoading = false);
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
    }
  }

  void _sendMagicLink() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập Email để nhận link"), backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? message = await auth.loginWithMagicLink(_emailController.text, context);
    setState(() => _isLoading = false);
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link đăng nhập đã được gửi vào Email của bạn!"), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (auth.email == 'admin@gmail.com') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // === Background với floating orbs ===
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primary.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.secondary.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          // === Content ===
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      // Logo / Icon
                      Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: AppTheme.glowShadow(AppTheme.primary),
                          ),
                          child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 44),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      const Center(
                        child: Text(
                          "Chào mừng trở lại!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "Đăng nhập để khám phá thế giới sách",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Email Field
                      _buildLabel("Email"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hint: "your@email.com",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      _buildLabel("Mật khẩu"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hint: "••••••••",
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                      const SizedBox(height: 12),
                      // Quên mật khẩu
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Quên mật khẩu?",
                            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: AppTheme.primary),
                              )
                            : Container(
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
                                  onPressed: _login,
                                  child: const Text(
                                    "Đăng nhập",
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Magic Link Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.primary.withOpacity(0.5), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                            backgroundColor: Colors.transparent,
                          ),
                          onPressed: _isLoading ? null : _sendMagicLink,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.mark_email_read_rounded, color: AppTheme.primary, size: 22),
                              SizedBox(width: 10),
                              Text(
                                "Nhận Link Đăng Nhập",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Google Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                          ),
                          onPressed: _isLoading ? null : _loginWithGoogle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network('https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png', height: 24),
                              const SizedBox(width: 12),
                              const Text(
                                "Đăng nhập bằng Google",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Register Link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, "/register"),
                          child: RichText(
                            text: const TextSpan(
                              text: "Chưa có tài khoản? ",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                              children: [
                                TextSpan(
                                  text: "Đăng ký ngay",
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
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
