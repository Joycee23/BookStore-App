import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/api_client.dart';

class ConfirmOrderScreen extends StatefulWidget {
  @override
  _ConfirmOrderScreenState createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  String? _discountMessage;
  double _discountAmount = 0;
  bool _isDiscountListVisible = false;
  String _selectedDiscountCode = '';
  String _selectedPaymentMethod = "Tiền mặt";
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    return Scaffold(
      appBar: AppBar(title: const Text("Xác nhận đơn hàng")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Thông tin giao hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: AppTheme.radiusMd,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _buildInfoTile(Icons.person_rounded, "Họ và tên", authProvider.fullName),
                  const Divider(color: Colors.white10, height: 24),
                  _buildInfoTile(Icons.phone_rounded, "Số điện thoại", authProvider.phoneNumber),
                  const Divider(color: Colors.white10, height: 24),
                  _buildInfoTile(Icons.location_on_rounded, "Địa chỉ", authProvider.address),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Phương thức thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: AppTheme.radiusMd,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  dropdownColor: AppTheme.bgCardLight,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                  isExpanded: true,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                  items: [
                    _buildPaymentItem("Tiền mặt", Icons.money_rounded, Colors.green),
                    _buildPaymentItem("Ví của tôi", Icons.account_balance_wallet_rounded, Colors.blue),
                    _buildPaymentItem("Chuyển khoản (PayOS)", Icons.qr_code_rounded, AppTheme.primary),
                  ],
                  onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Mã giảm giá", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _isDiscountListVisible = !_isDiscountListVisible),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: AppTheme.radiusMd,
                  border: Border.all(color: _selectedDiscountCode.isEmpty ? Colors.white.withOpacity(0.05) : AppTheme.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.discount_rounded, color: _selectedDiscountCode.isEmpty ? AppTheme.textMuted : AppTheme.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDiscountCode.isEmpty ? 'Chọn mã giảm giá' : _selectedDiscountCode,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _selectedDiscountCode.isEmpty ? AppTheme.textMuted : AppTheme.primary),
                        ),
                      ],
                    ),
                    Icon(_isDiscountListVisible ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                  ],
                ),
              ),
            ),
            if (_isDiscountListVisible) ...[
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight,
                  borderRadius: AppTheme.radiusMd,
                ),
                child: FutureBuilder<dynamic>(
                  future: ApiClient.get('/discounts?userId=${authProvider.userId}'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                    if (!snapshot.hasData || (snapshot.data as List).isEmpty) return const Center(child: Text('Không có mã giảm giá nào', style: TextStyle(color: AppTheme.textMuted)));

                    var discountCodes = (snapshot.data as List).where((d) => !(d['isUsed'] as bool)).toList();

                    return ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: discountCodes.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                      itemBuilder: (context, index) {
                        var codeData = discountCodes[index];
                        return ListTile(
                          title: Text(codeData['code'], style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                          subtitle: Text("Giảm: ${currencyFormat.format(codeData['amount'])}", style: const TextStyle(color: AppTheme.primary)),
                          trailing: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary),
                          onTap: () {
                            bool isExpired = DateTime.parse(codeData['expiryDate']).isBefore(DateTime.now());
                            if (!isExpired) {
                              setState(() {
                                _selectedDiscountCode = codeData['code'];
                                _discountAmount = (codeData['amount'] as num).toDouble();
                                _discountMessage = "Đã áp dụng mã giảm giá!";
                                _isDiscountListVisible = false;
                              });
                            } else {
                              setState(() => _discountMessage = "Mã giảm giá đã hết hạn!");
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
            if (_discountMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _discountMessage!,
                style: TextStyle(color: _discountMessage!.contains("hết hạn") ? Colors.redAccent : Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 32),
            // Tóm tắt đơn hàng
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: AppTheme.radiusMd,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("Tạm tính", currencyFormat.format(cartProvider.totalPrice)),
                  const SizedBox(height: 12),
                  if (_discountAmount > 0) ...[
                    _buildSummaryRow("Giảm giá", "-${currencyFormat.format(_discountAmount)}", color: Colors.greenAccent),
                    const SizedBox(height: 12),
                  ],
                  const Divider(color: Colors.white10, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng cộng", style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(
                        currencyFormat.format((cartProvider.totalPrice - _discountAmount) > 0 ? (cartProvider.totalPrice - _discountAmount) : 0),
                        style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
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
                  onPressed: () async => await placeOrder(context, authProvider, cartProvider, cartItems, _discountAmount, _selectedDiscountCode),
                  child: const Text("Xác nhận & Đặt hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildPaymentItem(String label, IconData icon, Color color) {
    return DropdownMenuItem(
      value: label,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color color = AppTheme.textPrimary}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> placeOrder(BuildContext context, AuthProvider auth, CartProvider cart, Map<String, dynamic> items, double discount, String code) async {
    double finalTotal = cart.totalPrice - discount;
    if (finalTotal < 0) finalTotal = 0;

    if (_selectedPaymentMethod == "Chuyển khoản (PayOS)") {
      Navigator.pushNamed(context, '/checkout');
      return;
    }

    try {
      final orderData = {
        'userId': auth.userId,
        'fullName': auth.fullName,
        'phoneNumber': auth.phoneNumber,
        'address': auth.address,
        'totalAmount': finalTotal,
        'originalAmount': cart.totalPrice,
        'usedDiscount': discount > 0,
        'discountCode': code.isNotEmpty ? code : null,
        'paymentMethod': _selectedPaymentMethod,
        'items': items.values.map((item) => {
          'bookId': item.id,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
      };

      await ApiClient.post('/orders', orderData);

      // Nếu dùng ví, update state ở frontend (backend đã trừ tiền)
      if (_selectedPaymentMethod == "Ví của tôi") {
        await auth.updateWalletBalance(auth.walletBalance - finalTotal);
      }

      cart.clearCart();
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }
}
