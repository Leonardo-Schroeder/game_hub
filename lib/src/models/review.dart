class Review {
  final String id;
  final String username;
  final String gameTitle;
  final double rating;
  final String content;
  final int likes;
  final int comments;

  const Review({
    required this.id,
    required this.username,
    required this.gameTitle,
    required this.rating,
    required this.content,
    required this.likes,
    required this.comments,
  });
}