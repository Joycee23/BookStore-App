import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/api_client.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      if (userId == null) return;

      final List<dynamic> fetchedOrders = await ApiClient.get('/orders?userId=$userId');

      setState(() {
        _orders = fetchedOrders.map((e) => e as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đơn hàng')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(30)),
                        child: const Icon(Icons.receipt_long_rounded, size: 48, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 20),
                      const Text("Chưa có đơn hàng nào", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (ctx, i) {
                    final order = _orders[i];
                    final createdAt = DateTime.parse(order['createdAt'].toString());
                    final items = order['items'] as List;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: AppTheme.radiusLg,
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Đơn hàng", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                child: Text(order['status'] == 'PAID' ? "Đã thanh toán" : "Đang xử lý", style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("#${order['orderCode'] ?? order['id'].toString().substring(0,8)}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 16),
                          ...items.map((orderItem) {
                            final item = orderItem['book'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item['imageUrl'] != '' 
                                        ? Image.network(item['imageUrl'], width: 50, height: 70, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.book, color: AppTheme.textMuted))
                                        : Container(width: 50, height: 70, color: AppTheme.bgCardLight, child: const Icon(Icons.book, color: AppTheme.textMuted)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("SL: ${orderItem['quantity']}", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                            Text(currencyFormat.format(orderItem['price']), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(color: Colors.white10, height: 24),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textMuted),
                              const SizedBox(width: 8),
                              Text(DateFormat('dd/MM/yyyy • HH:mm').format(createdAt), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.payment_rounded, size: 16, color: AppTheme.textMuted),
                              const SizedBox(width: 8),
                              Text(order['paymentMethod'] ?? "Tiền mặt", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Tổng thanh toán:", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                                Text(currencyFormat.format(order['totalAmount']), style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                              ],
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
