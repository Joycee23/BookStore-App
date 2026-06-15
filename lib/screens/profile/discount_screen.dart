import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:book_app/utils/app_theme.dart';
import 'package:book_app/providers/auth_provider.dart';
import 'package:book_app/utils/api_client.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({Key? key}) : super(key: key);

  @override
  _DiscountScreenState createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  List<Map<String, dynamic>> _discountCodes = [];
  bool _loading = true;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadDiscountCodes();
  }

  Future<void> _loadDiscountCodes() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      if (userId == null) return;

      final List<dynamic> fetchedCodes = await ApiClient.get('/discounts?userId=$userId');

      setState(() {
        _discountCodes = fetchedCodes.map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Lỗi khi tải mã giảm giá: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mã giảm giá")),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _discountCodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(30)),
                        child: const Icon(Icons.discount_outlined, size: 48, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 20),
                      const Text("Không có mã giảm giá", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _discountCodes.length,
                  itemBuilder: (context, index) {
                    var discount = _discountCodes[index];
                    bool isUsed = discount['isUsed'] ?? false;
                    bool isExpired = DateTime.parse(discount['expiryDate']).isBefore(DateTime.now());
                    bool isAvailable = !isUsed && !isExpired;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: AppTheme.radiusMd,
                        border: Border.all(color: isAvailable ? AppTheme.primary.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
                        boxShadow: [
                          if (isAvailable) BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              gradient: isAvailable ? AppTheme.primaryGradient : const LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                            ),
                            child: const Center(child: Icon(Icons.percent_rounded, color: Colors.white, size: 40)),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(discount['code'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isAvailable ? AppTheme.textPrimary : AppTheme.textMuted)),
                                      if (isUsed) const Text("Đã dùng", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w700))
                                      else if (isExpired) const Text("Hết hạn", style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Giảm ${currencyFormat.format((discount['amount'] as num).toDouble())}", style: TextStyle(color: isAvailable ? AppTheme.primary : AppTheme.textMuted, fontWeight: FontWeight.w700, fontSize: 15)),
                                  const SizedBox(height: 6),
                                  Text("HSD: ${_formatDate(discount['expiryDate'])}", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
