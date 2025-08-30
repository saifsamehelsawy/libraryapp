class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime joinedDate;
  final int favoriteCount;
  final int purchaseCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.joinedDate,
    required this.favoriteCount,
    required this.purchaseCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      favoriteCount: json['favoriteCount'] as int,
      purchaseCount: json['purchaseCount'] as int,
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
    };
  }
}
