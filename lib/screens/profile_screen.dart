import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/auth_provider.dart';
import 'return_info_screen.dart';
import 'return_policy_screen.dart';
import 'discount_screen.dart'; // Đúng với tên file hiện tại

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInfoVisible = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Cài đặt tài khoản", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Mục "Thông tin cá nhân"
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            title: const Text("Thông tin cá nhân"),
            subtitle: const Text("Xem và chỉnh sửa thông tin"),
            onTap: () {
              setState(() {
                _isInfoVisible = !_isInfoVisible;
              });
            },
          ),

          // Nếu mở, hiển thị thông tin cá nhân
          if (_isInfoVisible) ...[
            _buildInfoCard("Email", authProvider.email ?? "Chưa có"),
            _buildInfoCard("Họ và tên", authProvider.fullName),
            _buildInfoCard("Số điện thoại", authProvider.phoneNumber),
            _buildInfoCard("Địa chỉ nhận hàng", authProvider.address),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, "/edit_profile");
                },
                icon: const Icon(Icons.edit),
                label: const Text("Chỉnh sửa thông tin"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],

          const Divider(),

          // Nút mới: Ví
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
            title: const Text("Ví"),
            subtitle: const Text("Xem ví của tôi"),
            onTap: () {
              Navigator.pushNamed(context, "/wallet");
            },
          ),

          // Đơn đặt hàng
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.blue),
            title: const Text("Đơn đặt hàng"),
            subtitle: const Text("Xem thông tin đơn đặt hàng"),
            onTap: () {
              Navigator.pushNamed(context, "/orders");
            },
          ),

          // Mã giảm giá
          ListTile(
            leading: const Icon(Icons.discount, color: Colors.blue),
            title: const Text("Mã giảm giá"),
            subtitle: const Text("Xem danh sách mã giảm giá của bạn"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiscountScreen()),
              );
            },
          ),

          const Divider(),

          // Chính sách trả hàng
          ListTile(
            leading: const Icon(Icons.policy, color: Colors.green),
            title: const Text("Chính sách trả hàng"),
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => ReturnPolicyScreen()),
              );
            },
          ),

          // Thông tin trả hàng
          ListTile(
            leading: const Icon(Icons.assignment_return, color: Colors.orange),
            title: const Text("Thông tin trả hàng"),
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => ReturnInfoScreen()),
              );
            },
          ),

          const Divider(),

          // Đăng xuất
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              label: const Text("Đăng xuất"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
