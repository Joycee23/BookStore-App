import 'package:flutter/foundation.dart'; // Đảm bảo đã import ChangeNotifier
import 'package:book_app/models/discount_code.dart'; // Import DiscountCode
import 'package:book_app/utils/api_client.dart';

class DiscountProvider with ChangeNotifier {
  double _discountAmount = 0.0;
  String _discountMessage = "";

  double get discountAmount => _discountAmount;
  String get discountMessage => _discountMessage;

  // Phương thức kiểm tra mã giảm giá
  Future<bool> validateDiscountCode(String inputCode, String userId) async {
    try {
      final response = await ApiClient.post('/discounts/validate', {
        'code': inputCode,
        'userId': userId,
      });

      // Nếu API trả về dữ liệu (không ném lỗi) thì mã hợp lệ
      _discountAmount = (response['amount'] as num).toDouble();
      _discountMessage = "Mã giảm giá hợp lệ!";
      
      notifyListeners();
      return true;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('đã được sử dụng')) {
        _discountMessage = "Mã giảm giá đã được sử dụng!";
      } else if (errorStr.contains('không tồn tại')) {
        _discountMessage = "Mã giảm giá không tồn tại!";
      } else if (errorStr.contains('hết hạn')) {
        _discountMessage = "Mã giảm giá đã hết hạn!";
      } else {
        _discountMessage = "Mã giảm giá không hợp lệ!";
      }
      
      _discountAmount = 0;
      notifyListeners();
      return false;
    }
  }
}
