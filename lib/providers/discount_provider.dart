import 'package:flutter/foundation.dart'; // Đảm bảo đã import ChangeNotifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_app/models/discount_code.dart'; // Import DiscountCode

class DiscountProvider with ChangeNotifier {
  double _discountAmount = 0.0;
  String _discountMessage = "";

  double get discountAmount => _discountAmount;
  String get discountMessage => _discountMessage;

  // Phương thức kiểm tra mã giảm giá
  Future<bool> validateDiscountCode(String inputCode, String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('discount_codes')
          .where('code', isEqualTo: inputCode)
          .where('isUsed', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final discountCode = DiscountCode.fromMap(doc.id, doc.data() as Map<String, dynamic>);

        // Cập nhật discountAmount và thông báo
        _discountAmount = discountCode.discountAmount;
        _discountMessage = "Mã giảm giá hợp lệ!";

        // Cập nhật trạng thái của mã giảm giá trong Firestore
        await FirebaseFirestore.instance.collection('discount_codes').doc(doc.id).update({
          'isUsed': true,  // Đánh dấu mã đã sử dụng
        });

        // Lưu mã giảm giá đã sử dụng vào thông tin người dùng
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'usedDiscountCodes': FieldValue.arrayUnion([inputCode]),
        });

        notifyListeners();
        return true;
      } else {
        _discountMessage = "Mã giảm giá không hợp lệ hoặc đã sử dụng!";
        _discountAmount = 0;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _discountMessage = "Đã xảy ra lỗi khi kiểm tra mã!";
      _discountAmount = 0;
      notifyListeners();
      return false;
    }
  }
}
