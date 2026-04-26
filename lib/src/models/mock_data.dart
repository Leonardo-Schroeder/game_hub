import 'game.dart';
import 'review.dart';

class MockData {
  static const List<Game> featuredGames = [
    Game(
      id: 'g1',
      title: 'Cyberpunk 2077',
      genre: 'RPG',
      rating: 4.5,
      imageUrl: 'assets/images/cyber.jpg', // In a real app, an http URL
    ),
    Game(
      id: 'g2',
      title: 'Red Dead Redemption II',
      genre: 'Ação/Aventura',
      rating: 4.9,
      imageUrl: 'assets/images/red.jpg',
    ),
    Game(
      id: 'g3',
      title: 'Stardew Valley',
      genre: 'RPG/Simulação',
      rating: 4.95,
      imageUrl: 'assets/images/stardew.jpg',
    ),
  ];

  static const List<Review> recentReviews = [
    Review(
      id: 'r1',
      username: 'RPGMaster',
      gameTitle: 'Hollow Knight',
      rating: 4.0,
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
    Review(
      id: 'r3',
      username: 'ShaolinMatadorDePorco',
      gameTitle: 'Minecraft',
      rating: 5.0,
      content: 'Ulisses dá 10 para a gente',
      likes: 999,
      comments: 31,
    ),
  ];

  static const List<Game> catalogGames = [
    Game(id: '1', title: 'Hollow Knight', genre: 'Metroidvania', rating: 4.9, imageUrl: 'assets/images/hollow_knight.webp'),
    Game(id: '2', title: 'Stardew Valley', genre: 'Simulação', rating: 4.8, imageUrl: 'assets/images/stardew.jpg'),
    Game(id: '3', title: 'Cyberpunk 2077', genre: 'RPG', rating: 4.5, imageUrl: 'assets/images/cyber.jpg'),
    Game(id: '4', title: 'God of War', genre: 'Ação', rating: 4.9, imageUrl: 'assets/images/god_of_war.jpg'),
    Game(id: '5', title: 'Celeste', genre: 'Plataforma/Indie', rating: 4.8, imageUrl: 'assets/images/celeste.webp'),
    Game(id: '6', title: 'Hades', genre: 'Ação/Indie', rating: 4.9, imageUrl: 'assets/images/hades.jpg'),
  ];
}