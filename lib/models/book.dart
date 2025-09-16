class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final double price;
  final String category;
  final String description;

  // ✅ Thêm các thuộc tính giảm giá tạm thời
  final double? discountPercent; // phần trăm giảm (null nếu không giảm)
  final DateTime? discountEndDate; // ngày kết thúc giảm giá

  // ✅ Thêm thuộc tính sold để lưu số lượng đã bán
  final int sold; // số lượng đã bán

  // ✅ Thêm trường isVisible để xác định xem sách có hiển thị không
  final bool isVisible; // mặc định là true

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.description = 'Chưa có mô tả.',
    this.discountPercent,
    this.discountEndDate,
    this.sold = 0, // mặc định là 0 nếu không có thông tin
    this.isVisible = true, // mặc định là true nếu không có trường này
  });

  /// ✅ Kiểm tra sản phẩm còn trong thời gian giảm giá không
  bool get isDiscounted {
    if (discountPercent == null || discountEndDate == null) return false;
    return DateTime.now().isBefore(discountEndDate!);
  }

  /// ✅ Tính giá đã giảm nếu đang trong thời gian khuyến mãi
  double get discountedPrice {
    if (!isDiscounted) return price;
    return price * (1 - discountPercent! / 100);
  }

  // ✅ Chuyển từ JSON sang Book object
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? '',
      description: json['description'] ?? 'Chưa có mô tả.',
      discountPercent: json['discountPercent'] != null
          ? (json['discountPercent'] as num).toDouble()
          : null,
      discountEndDate: json['discountEndDate'] != null
          ? DateTime.parse(json['discountEndDate'])
          : null,
      sold: json['sold'] ?? 0,
      isVisible: json['isVisible'] ?? true, // Thêm trường isVisible
    );
  }

  // ✅ Chuyển từ Book object sang JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "author": author,
      "imageUrl": imageUrl,
      "price": price,
      "category": category,
      "description": description,
      if (discountPercent != null) "discountPercent": discountPercent,
      if (discountEndDate != null) "discountEndDate": discountEndDate!.toIso8601String(),
      "sold": sold,
      "isVisible": isVisible, // Lưu trường isVisible vào Firestore
    };
  }
}
