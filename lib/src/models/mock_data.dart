import 'game.dart';
import 'review.dart';

class MockData {
  static const List<Game> featuredGames = [
    Game(
      id: 'g1',
      title: 'Cyberpunk 2077',
      genre: 'RPG',
      rating: 4.5,
      imageUrl: 'cyberpunk', // In a real app, an http URL
    ),
    Game(
      id: 'g2',
      title: 'Red Dead Redemption II',
      genre: 'Ação/Aventura',
      rating: 4.9,
      imageUrl: 'rdr2',
    ),
  ];

  static const List<Review> recentReviews = [
    Review(
      id: 'r1',
      username: 'RPGMaster',
      gameTitle: 'Hollow Knight',
      rating: 5.0,
      content: 'Uma obra-prima absoluta! A atmosfera sombria e a jogabilidade fluida fazem deste um dos melhores metroidvanias já criados.',
      likes: 42,
      comments: 12,
    ),
    Review(
      id: 'r2',
      username: 'IndieExplorer',
      gameTitle: 'Stardew Valley',
      rating: 5.0,
      content: 'Simplesmente não consigo parar de jogar. A fazendinha é meu novo lar.',
      likes: 128,
      comments: 34,
    ),
  ];
}