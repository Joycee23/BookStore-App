class MyOrder {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final double originalAmount;
  final bool usedDiscount;
  final DateTime createdAt;
  final bool isReturned;
  final String status;

  MyOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.originalAmount,
    required this.usedDiscount,
    required this.createdAt,
    this.isReturned = false,
    this.status = 'pending',
  });

  factory MyOrder.fromMap(String id, Map<String, dynamic> data) {
    return MyOrder(
      id: id,
      userId: data['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      originalAmount: (data['originalAmount'] ?? 0).toDouble(),
      usedDiscount: data['usedDiscount'] ?? false,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt'].toString()) : DateTime.now(),
      isReturned: data['isReturned'] ?? false,
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
      'originalAmount': originalAmount,
      'usedDiscount': usedDiscount,
      'createdAt': createdAt.toIso8601String(),
      'isReturned': isReturned,
      'status': status,
    };
  }
}
