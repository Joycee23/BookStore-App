import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:book_app/providers/cart_provider.dart';
import 'package:book_app/providers/auth_provider.dart';
import 'package:book_app/utils/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  Future<void> _confirmOrder(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;

    if (userId == null) return;
    setState(() => _isLoading = true);

    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

    try {
      final items = cart.items.values.map((item) => {
        'bookId': item.id,
        'quantity': item.quantity,
      }).toList();

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giỏ hàng đang trống!")));
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse('$apiUrl/api/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'items': items,
          'cancelUrl': 'https://localhost:3000/cancel', 
          'returnUrl': 'https://localhost:3000/success',
        }),
      );

      if (response.statusCode == 200) {
        final checkoutUrl = json.decode(response.body)['checkoutUrl'];
        if (checkoutUrl != null) {
          final uri = Uri.parse(checkoutUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            cart.clearCart();
            Navigator.pop(context);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${json.decode(response.body)['error']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi thanh toán: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán PayOS')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppTheme.glowShadow(AppTheme.primary),
                ),
                child: const Icon(Icons.qr_code_2_rounded, size: 64, color: AppTheme.primary),
              ),
              const SizedBox(height: 32),
              const Text("Chuyển hướng thanh toán", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              const Text("Bạn sẽ được chuyển hướng tới cổng thanh toán an toàn của PayOS.", textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity, height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: AppTheme.radiusMd,
                    boxShadow: AppTheme.glowShadow(AppTheme.primary),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd)),
                    onPressed: _isLoading ? null : () => _confirmOrder(context),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Tiến hành thanh toán", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
