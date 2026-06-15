import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'return_request_detail_screen.dart';
import '../utils/app_theme.dart';
import '../utils/api_client.dart';

class ReturnRequestsScreen extends StatefulWidget {
  const ReturnRequestsScreen({super.key});

  @override
  State<ReturnRequestsScreen> createState() => _ReturnRequestsScreenState();
}

class _ReturnRequestsScreenState extends State<ReturnRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final List<dynamic> requests = await ApiClient.get('/return_requests');
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: AppTheme.bgCardLight, borderRadius: BorderRadius.circular(30)),
                        child: const Icon(Icons.assignment_return_rounded, size: 48, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 20),
                      const Text("Chưa có đơn trả hàng nào", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final data = _requests[index];

                    final name = data['name'] ?? 'Không rõ';
                    final phone = data['phone'] ?? 'N/A';
                    final address = data['address'] ?? 'Chưa có địa chỉ';
                    final product = data['product'] ?? 'Không xác định';
                    final reason = data['reason'] ?? 'Không có lý do';
                    final status = data['status'] ?? 'Chưa xử lý';
                    final formattedDate = data['createdAt'] != null ? DateFormat('dd/MM/yyyy • HH:mm').format(DateTime.parse(data['createdAt'].toString())) : '---';
                    final String? imageUrl = data['imageUrl'];

                    Color statusColor = status == 'Đã duyệt' ? Colors.greenAccent : (status == 'Đang xử lý' ? Colors.orangeAccent : AppTheme.textMuted);
                    Color statusBg = status == 'Đã duyệt' ? Colors.greenAccent.withOpacity(0.12) : (status == 'Đang xử lý' ? Colors.orangeAccent.withOpacity(0.12) : AppTheme.bgCardLight);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: AppTheme.radiusLg,
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book image
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              child: Image.network(
                                imageUrl,
                                height: 160, width: double.infinity, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(height: 160, color: AppTheme.bgCardLight, child: const Icon(Icons.image_not_supported_rounded, color: AppTheme.textMuted, size: 48)),
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status + product name
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(product, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 17), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withOpacity(0.4))),
                                      child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white10, height: 1),
                                const SizedBox(height: 16),
                                _buildInfoRow(Icons.person_rounded, name, Colors.blue),
                                const SizedBox(height: 10),
                                _buildInfoRow(Icons.phone_rounded, phone, Colors.greenAccent),
                                const SizedBox(height: 10),
                                _buildInfoRow(Icons.location_on_rounded, address, Colors.redAccent),
                                const SizedBox(height: 10),
                                _buildInfoRow(Icons.info_outline_rounded, reason, Colors.orangeAccent),
                                const SizedBox(height: 10),
                                _buildInfoRow(Icons.access_time_rounded, formattedDate, AppTheme.textMuted),
                                if (status == 'Chưa xử lý') ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ReturnRequestDetailScreen(returnId: data['id']))).then((_) => _fetchRequests());
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: AppTheme.radiusMd),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                                            SizedBox(width: 8),
                                            Text("Xử lý yêu cầu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4))),
      ],
    );
  }
}
