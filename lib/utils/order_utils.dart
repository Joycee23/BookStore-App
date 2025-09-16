import 'dart:math';

class OrderUtils {
  static String generateOrderId() {
    final now = DateTime.now();
    final random = Random();
    final randomDigits = random.nextInt(999999).toString().padLeft(6, '0');
    return 'ORD${now.year}${now.month}${now.day}$randomDigits';
  }
}
