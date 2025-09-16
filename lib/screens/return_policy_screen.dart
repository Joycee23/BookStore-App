import 'package:flutter/material.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Chính Sách Đổi Trả Hàng Hóa"),
        centerTitle: true,
        elevation: 1,
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PolicySection(
                title: "1. PHẠM VI ÁP DỤNG",
                contents: [
                  "a. Việc đổi trả hàng hóa chỉ được áp dụng đối với những đơn hàng đặt dư so với nhu cầu sử dụng thực tế...",
                  "b. Trường hợp sản phẩm được xác định là không thể sử dụng, hàng giả, hàng nhái hoặc hàng không đạt chất lượng...",
                ],
              ),
              Divider(),
              PolicySection(
                title: "2. CHÍNH SÁCH TRẢ HÀNG",
                contents: [
                  "a. Trong thời gian mười lăm (15) ngày...",
                  "b. Sau thời gian mười lăm (15) ngày...",
                  "c. Giá trị trả hàng không vượt quá 10%...",
                  "d. Sản phẩm được trả phải đáp ứng đầy đủ...",
                ],
              ),
              Divider(),
              PolicySection(
                title: "3. CHÍNH SÁCH ĐỔI HÀNG",
                contents: [
                  "a. Trong thời gian mười lăm (15) ngày...",
                  "b. Sau thời gian mười lăm (15) ngày...",
                  "c. Giá trị sản phẩm đổi phải ngang bằng...",
                  "d. Trong trường hợp khách hàng đặt cọc...",
                  "e. Sản phẩm được đổi phải đáp ứng...",
                ],
              ),
              Divider(),
              PolicySection(
                title: "4. ĐIỀU KIỆN ĐỔI TRẢ HÀNG",
                contents: [
                  "a. Không có dấu hiệu đã qua sử dụng...",
                  "b. Không bị lỗi về hình thức...",
                  "c. Đầy đủ bao bì, phụ kiện...",
                  "d. Có đầy đủ các chứng từ kèm theo...",
                  "e. Đối với Khách hàng cá nhân...",
                  "f. Đối với Khách hàng là công ty...",
                ],
              ),
              Divider(),
              PolicySection(
                title: "5. QUY TRÌNH THỰC HIỆN ĐỔI TRẢ HÀNG HÓA",
                contents: [
                  "a. Bước 1: Khách hàng liên hệ...",
                  "b. Bước 2: Book Store sẽ kiểm tra...",
                  "c. Bước 3: Sau khi đã xác minh...",
                  "d. Bước 4: Nhân viên bán hàng xác nhận...",
                  "e. Bước 6: Khách hàng vận chuyển hàng...",
                ],
              ),
              Divider(),
              PolicySection(
                title: "6. CHÍNH SÁCH HOÀN TIỀN VÀ PHÍ XỬ LÝ",
                contents: [
                  "a. Book Store sẽ hỗ trợ Khách hàng...",
                  "b. Đơn hàng thanh toán tiền mặt...",
                  "c. Đơn hàng thanh toán chuyển khoản...",
                  "d. Lưu ý: Hoàn lại giá trị sản phẩm đã thanh toán...",
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class PolicySection extends StatelessWidget {
  final String title;
  final List<String> contents;

  const PolicySection({
    Key? key,
    required this.title,
    required this.contents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
        ),
        const SizedBox(height: 8),
        ...contents.map((text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SelectableText(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}
