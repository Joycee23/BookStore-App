import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chính Sách Đổi Trả")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PolicyHeader(),
            SizedBox(height: 24),
            _PolicySection(
              number: "01",
              title: "Phạm vi áp dụng",
              contents: [
                "Việc đổi trả hàng hóa chỉ được áp dụng đối với những đơn hàng đặt dư so với nhu cầu sử dụng thực tế.",
                "Trường hợp sản phẩm được xác định là không thể sử dụng, hàng giả, hàng nhái hoặc hàng không đạt chất lượng sẽ được xử lý theo quy định riêng.",
              ],
            ),
            _PolicySection(
              number: "02",
              title: "Chính sách trả hàng",
              contents: [
                "Trong thời gian 15 ngày kể từ ngày nhận hàng, khách hàng có thể yêu cầu trả hàng.",
                "Sau thời gian 15 ngày, Book Store có quyền từ chối yêu cầu trả hàng.",
                "Giá trị trả hàng không vượt quá 10% giá trị đơn hàng.",
                "Sản phẩm được trả phải đáp ứng đầy đủ điều kiện quy định.",
              ],
            ),
            _PolicySection(
              number: "03",
              title: "Chính sách đổi hàng",
              contents: [
                "Trong thời gian 15 ngày kể từ ngày nhận hàng, khách hàng có thể yêu cầu đổi hàng.",
                "Giá trị sản phẩm đổi phải ngang bằng hoặc cao hơn sản phẩm ban đầu.",
                "Trong trường hợp khách hàng đặt cọc, phần chênh lệch sẽ được hoàn trả.",
                "Sản phẩm được đổi phải đáp ứng đầy đủ điều kiện quy định.",
              ],
            ),
            _PolicySection(
              number: "04",
              title: "Điều kiện đổi trả hàng",
              contents: [
                "Không có dấu hiệu đã qua sử dụng.",
                "Không bị lỗi về hình thức như trầy xước, móp méo.",
                "Đầy đủ bao bì, phụ kiện kèm theo.",
                "Có đầy đủ các chứng từ kèm theo như hóa đơn, phiếu bảo hành.",
              ],
            ),
            _PolicySection(
              number: "05",
              title: "Quy trình thực hiện đổi trả",
              contents: [
                "Bước 1: Khách hàng liên hệ hotline hoặc điền form trả hàng trong app.",
                "Bước 2: Book Store sẽ kiểm tra và xác nhận yêu cầu trong 24-48 giờ.",
                "Bước 3: Sau khi xác minh, khách hàng gửi hàng về kho của Book Store.",
                "Bước 4: Nhân viên kiểm tra sản phẩm và xử lý đổi/trả theo yêu cầu.",
              ],
            ),
            _PolicySection(
              number: "06",
              title: "Chính sách hoàn tiền",
              contents: [
                "Book Store sẽ hỗ trợ khách hàng hoàn tiền trong vòng 5-7 ngày làm việc.",
                "Đơn hàng thanh toán tiền mặt: hoàn tiền mặt hoặc chuyển khoản.",
                "Đơn hàng thanh toán chuyển khoản: hoàn tiền về tài khoản gốc.",
                "Lưu ý: Phí vận chuyển trong quá trình đổi trả do khách hàng chịu.",
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PolicyHeader extends StatelessWidget {
  const _PolicyHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.radiusLg,
        boxShadow: AppTheme.glowShadow(AppTheme.primary),
      ),
      child: Column(
        children: [
          const Icon(Icons.policy_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            "Chính Sách Đổi Trả",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "Vui lòng đọc kỹ trước khi yêu cầu đổi trả",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String number;
  final String title;
  final List<String> contents;

  const _PolicySection({required this.number, required this.title, required this.contents});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(number, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...contents.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
