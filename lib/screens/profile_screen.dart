import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/auth_provider.dart';
import 'return_info_screen.dart';
import 'return_policy_screen.dart';
import 'discount_screen.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // === Header ===
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppTheme.glowShadow(AppTheme.primary),
                      ),
                      child: Center(
                        child: Text(
                          (authProvider.fullName.isNotEmpty ? authProvider.fullName[0] : "U").toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authProvider.fullName.isNotEmpty ? authProvider.fullName : "Người dùng",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.email ?? "",
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    // Quick Info Cards
                    Row(
                      children: [
                        _buildQuickCard(
                          context,
                          icon: Icons.account_balance_wallet_rounded,
                          label: "Ví",
                          value: "${authProvider.walletBalance.toStringAsFixed(0)}₫",
                          gradient: AppTheme.walletGradient,
                          onTap: () => Navigator.pushNamed(context, "/wallet"),
                        ),
                        const SizedBox(width: 12),
                        _buildQuickCard(
                          context,
                          icon: Icons.receipt_long_rounded,
                          label: "Đơn hàng",
                          value: "Xem",
                          gradient: AppTheme.accentGradient,
                          onTap: () => Navigator.pushNamed(context, "/orders"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // === Menu Items ===
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text("Tài khoản", style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: "Chỉnh sửa hồ sơ",
                    subtitle: "Cập nhật thông tin cá nhân",
                    onTap: () => Navigator.pushNamed(context, "/edit_profile"),
                  ),
                  _buildMenuItem(
                    icon: Icons.discount_outlined,
                    title: "Mã giảm giá",
                    subtitle: "Xem danh sách mã của bạn",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiscountScreen())),
                  ),
                  const SizedBox(height: 20),
                  const Text("Hỗ trợ", style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.policy_outlined,
                    title: "Chính sách trả hàng",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReturnPolicyScreen())),
                  ),
                  _buildMenuItem(
                    icon: Icons.assignment_return_outlined,
                    title: "Thông tin trả hàng",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReturnInfoScreen())),
                  ),
                  const SizedBox(height: 28),
                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                      ),
                      onPressed: () {
                        authProvider.logout();
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Đăng xuất", style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppTheme.radiusMd,
            boxShadow: [
              BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: AppTheme.radiusMd,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
