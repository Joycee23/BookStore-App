import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../admin_screen/admin_home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  void _login() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Gọi hàm login từ AuthProvider
    String? message = await auth.login(email, password, context); 

    setState(() => _isLoading = false);

    // Kiểm tra xem message có phải là null không trước khi hiển thị
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    if (auth.isAuthenticated) {
      if (email == "admin@gmail.com") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      } else {
        // Kiểm tra nếu người dùng đã có thông tin cá nhân
        if (auth.hasUserInfo) {  
          // Nếu đã có thông tin cá nhân, chuyển đến trang Home
          Navigator.pushReplacementNamed(context, "/home");
        } else {
          // Nếu chưa có thông tin cá nhân, chuyển đến trang nhập thông tin cá nhân
          Navigator.pushReplacementNamed(context, "/user_info");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đăng nhập"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("Email"),
            _buildTextField(_emailController, "Nhập email của bạn", TextInputType.emailAddress, false),
            _buildTitle("Mật khẩu"),
            _buildTextField(_passwordController, "Nhập mật khẩu", TextInputType.text, true),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value!),
                      activeColor: Colors.blueAccent,
                    ),
                    const Text("Nhớ mật khẩu", style: TextStyle(fontSize: 14)),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Quên mật khẩu?",
                    style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _login,
                      child: const Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                    ),
                  ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/register"),
                child: Text(
                  "Chưa có tài khoản? Đăng ký ngay",
                  style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType keyboardType, bool isPassword) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
