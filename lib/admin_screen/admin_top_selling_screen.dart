import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../utils/api_client.dart';

class AdminTopSellingScreen extends StatefulWidget {
  const AdminTopSellingScreen({Key? key}) : super(key: key);

  @override
  State<AdminTopSellingScreen> createState() => _AdminTopSellingScreenState();
}

class _AdminTopSellingScreenState extends State<AdminTopSellingScreen> {
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _bookOrderMap = {};

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final List<dynamic> orders = await ApiClient.get('/orders');
      final processed = _processOrderData(orders);
      if (mounted) {
        setState(() {
          _bookOrderMap = processed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, Map<String, dynamic>> _processOrderData(List<dynamic> orders) {
    Map<String, Map<String, dynamic>> tempMap = {};
    for (var order in orders) {
      if (order['items'] != null) {
        for (var item in order['items']) {
          final book = item['book'];
          if (book == null) continue;
          String title = book['title'] ?? 'Không tên';
          int price = (book['price'] is double) ? (book['price'] as double).toInt() : (book['price'] ?? 0);
          int quantity = (item['quantity'] is double) ? (item['quantity'] as double).toInt() : (item['quantity'] ?? 0);
          String imageUrl = book['imageUrl'] ?? '';
          if (tempMap.containsKey(title)) {
            tempMap[title]!['quantity'] += quantity;
          } else {
            tempMap[title] = {'imageUrl': imageUrl, 'price': price, 'quantity': quantity};
          }
        }
      }
    }
    var sorted = tempMap.entries.toList()..sort((a, b) => b.value['quantity'].compareTo(a.value['quantity']));
    return Map.fromEntries(sorted);
  }

  Widget _buildBarChart(Map<String, Map<String, dynamic>> dataMap) {
    if (dataMap.isEmpty) return const SizedBox.shrink();

    final entries = dataMap.entries.take(7).toList();
    final maxQty = entries.map<int>((e) => e.value['quantity'] as int).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Biểu đồ bán chạy", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.6,
            child: BarChart(
              BarChartData(
                maxY: maxQty.toDouble() + 3,
                barGroups: entries.asMap().entries.map((e) {
                  final qty = e.value.value['quantity'] as int;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: qty.toDouble(),
                        gradient: AppTheme.primaryGradient,
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxQty > 5 ? (maxQty / 5).ceilToDouble() : 1,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                      reservedSize: 28,
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _bookOrderMap.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 100, height: 100, decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(30)),
                          child: const Icon(Icons.bar_chart_rounded, size: 48, color: AppTheme.textMuted)),
                      const SizedBox(height: 20),
                      const Text("Chưa có dữ liệu đơn hàng", style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBarChart(_bookOrderMap),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Row(
                          children: [
                            const Text("Xếp hạng", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
                            const Spacer(),
                            Text("${_bookOrderMap.length} sách", style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _bookOrderMap.length,
                        itemBuilder: (context, index) {
                          String title = _bookOrderMap.keys.elementAt(index);
                          final data = _bookOrderMap[title]!;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard,
                              borderRadius: AppTheme.radiusMd,
                              border: Border.all(
                                color: index < 3 ? AppTheme.primary.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Rank badge
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    gradient: index == 0 ? AppTheme.primaryGradient : (index == 1 ? AppTheme.accentGradient : (index == 2 ? AppTheme.walletGradient : null)),
                                    color: index >= 3 ? AppTheme.bgCardLight : null,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text('${index + 1}', style: TextStyle(color: index < 3 ? Colors.white : AppTheme.textMuted, fontWeight: FontWeight.w800, fontSize: 13))),
                                ),
                                const SizedBox(width: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: data['imageUrl'] != ''
                                      ? Image.network(data['imageUrl'], width: 46, height: 60, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(width: 46, height: 60, color: AppTheme.bgCardLight, child: const Icon(Icons.book, color: AppTheme.textMuted, size: 20)))
                                      : Container(width: 46, height: 60, color: AppTheme.bgCardLight, child: const Icon(Icons.book, color: AppTheme.textMuted, size: 20)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(currencyFormatter.format(data['price']), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(8)),
                                            child: Text('${data['quantity']} đã bán', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
