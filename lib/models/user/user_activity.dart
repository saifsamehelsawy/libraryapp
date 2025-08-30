class UserActivity {
  final String id;
  final String userId;
  final String bookId;
  final ActivityType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  UserActivity({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookId: json['bookId'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
        orElse: () => ActivityType.view,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  UserActivity copyWith({
    String? id,
    String? userId,
    String? bookId,
    ActivityType? type,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return UserActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum ActivityType {
  view, // User viewed book details
  purchase, // User purchased a book
  favorite, // User favorited/unfavorited a book
  rate, // User rated a book
  review, // User reviewed a book
  share, // User shared a book
}
