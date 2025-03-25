class TravelNote {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? location;
  final List<String>? images;
  final double? expense;
  final String? category; // Loại ghi chú: 'Ẩm thực', 'Khách sạn', 'Di chuyển', 'Tham quan', etc.
  final String? weather; // Thời tiết
  final int? rating; // Đánh giá (1-5 sao)

  TravelNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.images,
    this.expense,
    this.category,
    this.weather,
    this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'location': location,
      'images': images,
      'expense': expense,
      'category': category,
      'weather': weather,
      'rating': rating,
    };
  }

  factory TravelNote.fromMap(Map<String, dynamic> map) {
    return TravelNote(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      location: map['location'],
      images: map['images'] != null ? List<String>.from(map['images']) : null,
      expense: map['expense']?.toDouble(),
      category: map['category'],
      weather: map['weather'],
      rating: map['rating'],
    );
  }
} 