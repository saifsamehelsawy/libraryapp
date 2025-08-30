class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime joinedDate;
  final int favoriteCount;
  final int purchaseCount;
  final Map<String, double>? bookRatings;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.joinedDate,
    this.favoriteCount = 0,
    this.purchaseCount = 0,
    this.bookRatings,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      purchaseCount: json['purchaseCount'] as int? ?? 0,
      bookRatings: (json['bookRatings'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'joinedDate': joinedDate.toIso8601String(),
      'favoriteCount': favoriteCount,
      'purchaseCount': purchaseCount,
      'bookRatings': bookRatings,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? joinedDate,
    int? favoriteCount,
    int? purchaseCount,
    Map<String, double>? bookRatings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      joinedDate: joinedDate ?? this.joinedDate,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      purchaseCount: purchaseCount ?? this.purchaseCount,
      bookRatings: bookRatings ?? this.bookRatings,
    );
  }
}
