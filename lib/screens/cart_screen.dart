import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import 'confirm_order_screen.dart';
import '../utils/app_theme.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cartItems = cart.items;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.textMuted),
              onPressed: () {
                final userId = auth.userId ?? '';
                cart.clearCart();
              },
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCardLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Giỏ hàng trống",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hãy thêm sách yêu thích vào giỏ hàng!",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, index) {
                      final productId = cartItems.keys.toList()[index];
                      final item = cartItems[productId]!;

                      return Dismissible(
                        key: ValueKey(productId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          final userId = auth.userId ?? '';
                          cart.removeItem(userId, productId);
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: AppTheme.radiusMd,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 28),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: AppTheme.radiusMd,
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              // Book image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item.imageUrl.startsWith('http')
                                    ? Image.network(item.imageUrl, width: 70, height: 90, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 70, height: 90, color: AppTheme.bgCardLight,
                                          child: const Icon(Icons.book, color: AppTheme.textMuted),
                                        ))
                                    : Image.asset(item.imageUrl, width: 70, height: 90, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary),
                                      maxLines: 2, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      currencyFormat.format(item.price),
                                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCardLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildQtyBtn(Icons.remove_rounded, () {
                                      if (item.quantity > 1) {
                                        cart.updateItemQuantity(auth.userId ?? '', productId, item.quantity - 1);
                                      }
                                    }),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                      ),
                                    ),
                                    _buildQtyBtn(Icons.add_rounded, () {
                                      cart.updateItemQuantity(auth.userId ?? '', productId, item.quantity + 1);
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // === Bottom ===
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng tiền", style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                          Text(
                            currencyFormat.format(cart.totalPrice),
                            style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ConfirmOrderScreen()));
                            },
                            child: const Text("Đặt Hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 18),
      ),
    );
  }
}
