import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../utils/api_client.dart';

class ReturnRequestDetailScreen extends StatefulWidget {
  final String returnId;

  const ReturnRequestDetailScreen({super.key, required this.returnId});

  @override
  State<ReturnRequestDetailScreen> createState() => _ReturnRequestDetailScreenState();
}

class _ReturnRequestDetailScreenState extends State<ReturnRequestDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final data = await ApiClient.get('/return_requests/${widget.returnId}');
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptReturn() async {
    if (_data == null) return;
    setState(() => _isProcessing = true);
    
    try {
      await ApiClient.put('/return_requests/${widget.returnId}', {'status': 'Đã duyệt'});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Xử lý trả hàng thành công!'),
            backgroundColor: AppTheme.bgCardLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.returnId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chi tiết đơn trả")),
        body: const Center(child: Text("Mã đơn trả hàng không hợp lệ.", style: TextStyle(color: AppTheme.textSecondary))),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chi tiết đơn trả")),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chi tiết đơn trả")),
        body: const Center(child: Text("Không tìm thấy đơn trả hàng.", style: TextStyle(color: AppTheme.textSecondary))),
      );
    }

    final data = _data!;
    final name = data['name'] ?? 'Không rõ';
    final phone = data['phone'] ?? 'N/A';
    final address = data['address'] ?? 'Chưa có địa chỉ';
    final product = data['product'] ?? 'Không xác định';
    final reason = data['reason'] ?? 'Không có lý do';
    final status = data['status'] ?? 'Chưa xử lý';
    final formattedDate = data['createdAt'] != null ? DateFormat('dd/MM/yyyy • HH:mm').format(DateTime.parse(data['createdAt'].toString())) : '---';
    final String? imageUrl = data['imageUrl'];
    final String orderCode = data['orderCode'] ?? 'Không rõ';
    final String userId = data['userId'] ?? '';

    Color statusColor = status == 'Đã duyệt' ? Colors.greenAccent : (status == 'Đang xử lý' ? Colors.orangeAccent : AppTheme.textMuted);
    Color statusBg = status == 'Đã duyệt' ? Colors.greenAccent.withOpacity(0.12) : (status == 'Đang xử lý' ? Colors.orangeAccent.withOpacity(0.12) : AppTheme.bgCardLight);

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết đơn trả")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Image ===
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: AppTheme.radiusLg,
                child: Image.network(
                  imageUrl,
                  height: 220, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 220, color: AppTheme.bgCardLight, child: const Icon(Icons.image_not_supported_rounded, color: AppTheme.textMuted, size: 48)),
                ),
              ),

            const SizedBox(height: 20),

            // === Status ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: statusBg, borderRadius: AppTheme.radiusMd, border: Border.all(color: statusColor.withOpacity(0.4))),
              child: Row(
                children: [
                  Icon(status == 'Đã duyệt' ? Icons.check_circle_rounded : Icons.pending_rounded, color: statusColor),
                  const SizedBox(width: 12),
                  Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // === Info Card ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: AppTheme.radiusMd,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Thông tin đơn trả", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.shopping_bag_rounded, "Sản phẩm", product, Colors.blue),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.person_rounded, "Người trả", name, Colors.purpleAccent),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.phone_rounded, "Số điện thoại", phone, Colors.greenAccent),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.location_on_rounded, "Địa chỉ", address, Colors.redAccent),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.report_problem_rounded, "Lý do trả", reason, Colors.orangeAccent),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.receipt_rounded, "Mã đơn hàng", orderCode, AppTheme.primary),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.access_time_rounded, "Thời gian", formattedDate, AppTheme.textMuted),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // === Action Button ===
            if (status == 'Chưa xử lý')
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
                    borderRadius: AppTheme.radiusMd,
                    boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd)),
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                    label: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text("Chấp nhận hoàn hàng", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                    onPressed: _isProcessing ? null : _acceptReturn,
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
