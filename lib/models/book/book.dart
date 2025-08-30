import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String coverUrl;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final double rating;

  @HiveField(7)
  final int reviewCount;

  @HiveField(8)
  final bool isFavorite;

  @HiveField(9)
  final bool isPurchased;

  @HiveField(10)
  final DateTime publishedDate;

  @HiveField(11)
  final String category;

  @HiveField(12)
  final int pageCount;

  @HiveField(13)
  final String language;

  @HiveField(14)
  final String publisher;

  @HiveField(15)
  final String isbn;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
    this.isPurchased = false,
    required this.publishedDate,
    required this.category,
    required this.pageCount,
    required this.language,
    required this.publisher,
    required this.isbn,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    double? price,
    double? rating,
    int? reviewCount,
    bool? isFavorite,
    bool? isPurchased,
    DateTime? publishedDate,
    String? category,
    int? pageCount,
    String? language,
    String? publisher,
    String? isbn,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isPurchased: isPurchased ?? this.isPurchased,
      publishedDate: publishedDate ?? this.publishedDate,
      category: category ?? this.category,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      publisher: publisher ?? this.publisher,
      isbn: isbn ?? this.isbn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFavorite': isFavorite,
      'isPurchased': isPurchased,
      'publishedDate': publishedDate.toIso8601String(),
      'category': category,
      'pageCount': pageCount,
      'language': language,
      'publisher': publisher,
      'isbn': isbn,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      coverUrl: json['coverUrl'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPurchased: json['isPurchased'] as bool? ?? false,
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      category: json['category'] as String,
      pageCount: json['pageCount'] as int,
      language: json['language'] as String,
      publisher: json['publisher'] as String,
      isbn: json['isbn'] as String,
    );
  }
}
