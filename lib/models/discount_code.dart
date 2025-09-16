class DiscountCode {
  final String id;
  final String code;
  final double discountAmount;
  final bool isUsed;

  DiscountCode({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.isUsed,
  });

  factory DiscountCode.fromMap(String id, Map<String, dynamic> map) {
    return DiscountCode(
      id: id,
      code: map['code'],
      discountAmount: map['discountAmount']?.toDouble() ?? 0.0,
      isUsed: map['isUsed'] ?? false,
    );
  }
}
