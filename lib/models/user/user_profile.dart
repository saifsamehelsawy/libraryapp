import 'user.dart';

class UserProfile extends User {
  final String? avatarUrl;
  final String? bio;
  final String? address;
  final Map<String, dynamic> preferences;
  final List<String> readingHistory;
  final Map<String, double> bookRatings; // bookId: rating

  UserProfile({
    required String id,
    required String email,
    required String name,
    String? phoneNumber,
    required DateTime createdAt,
    required DateTime lastLoginAt,
    bool isEmailVerified = false,
    this.avatarUrl,
    this.bio,
    this.address,
    this.preferences = const {},
    this.readingHistory = const [],
    this.bookRatings = const {},
    List<String> purchasedBooks = const [],
    List<String> favoriteBooks = const [],
  }) : super(
          id: id,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
          isEmailVerified: isEmailVerified,
          purchasedBooks: purchasedBooks,
          favoriteBooks: favoriteBooks,
        );

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      preferences: Map<String, dynamic>.from(json['preferences'] as Map? ?? {}),
      readingHistory: List<String>.from(json['readingHistory'] as List? ?? []),
      bookRatings: Map<String, double>.from(json['bookRatings'] as Map? ?? {}),
      purchasedBooks: List<String>.from(json['purchasedBooks'] as List? ?? []),
      favoriteBooks: List<String>.from(json['favoriteBooks'] as List? ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'avatarUrl': avatarUrl,
      'bio': bio,
      'address': address,
      'preferences': preferences,
      'readingHistory': readingHistory,
      'bookRatings': bookRatings,
    };
  }

  @override
  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    List<String>? favoriteBooks,
    List<String>? purchasedBooks,
    // UserProfile specific fields
    String? avatarUrl,
    String? bio,
    String? address,
    Map<String, dynamic>? preferences,
    List<String>? readingHistory,
    Map<String, double>? bookRatings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
      readingHistory: readingHistory ?? this.readingHistory,
      bookRatings: bookRatings ?? this.bookRatings,
      purchasedBooks: purchasedBooks ?? this.purchasedBooks,
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
    );
  }
}
