class BookCategory {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int bookCount;

  BookCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.bookCount = 0,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      bookCount: json['bookCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'bookCount': bookCount,
    };
  }

  BookCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    int? bookCount,
  }) {
    return BookCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      bookCount: bookCount ?? this.bookCount,
    );
  }
}
