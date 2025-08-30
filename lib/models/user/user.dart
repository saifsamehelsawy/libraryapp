class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> favoriteBooks;
  final List<String> purchasedBooks;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    required this.createdAt,
    required this.lastLoginAt,
    this.favoriteBooks = const [],
    this.purchasedBooks = const [],
    this.isEmailVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      favoriteBooks: List<String>.from(json['favoriteBooks'] as List? ?? []),
      purchasedBooks: List<String>.from(json['purchasedBooks'] as List? ?? []),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'favoriteBooks': favoriteBooks,
      'purchasedBooks': purchasedBooks,
      'isEmailVerified': isEmailVerified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? favoriteBooks,
    List<String>? purchasedBooks,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      purchasedBooks: purchasedBooks ?? this.purchasedBooks,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
