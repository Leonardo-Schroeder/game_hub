class Review {
  final String id;
  final String userId; // Importante para sabermos de quem é a resenha
  final String username;
  final String gameTitle;
  final double rating;
  final String content;
  final bool recommend;
  final String platform;
  final bool hasSpoilers;
  final DateTime createdAt;
  final int likes;
  final int comments;

  Review({
    required this.id,
    required this.userId,
    required this.username,
    required this.gameTitle,
    required this.rating,
    required this.content,
    required this.recommend,
    required this.platform,
    required this.hasSpoilers,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'gameTitle': gameTitle,
      'rating': rating,
      'content': content,
      'recommend': recommend,
      'platform': platform,
      'hasSpoilers': hasSpoilers,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      gameTitle: map['gameTitle'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      content: map['content'] ?? '',
      recommend: map['recommend'] ?? true,
      platform: map['platform'] ?? 'PC',
      hasSpoilers: map['hasSpoilers'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
    );
  }
}