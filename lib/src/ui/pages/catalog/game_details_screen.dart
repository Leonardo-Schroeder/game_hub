// lib/src/ui/pages/catalog/game_details_screen.dart
import 'package:flutter/material.dart';
import 'package:game_hub/src/ui/pages/review/review_screen.dart';
import '../../../models/game.dart';
import '../../../models/mock_data.dart';
import '../../widgets/review_card.dart';

class GameDetailsScreen extends StatelessWidget {
  final Game game;

  const GameDetailsScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Para simplificar, vamos pegar as resenhas do MockData para demonstrar
    // No app final, vamos fazer um filtro: reviews.where((r) => r.gameTitle == game.title)
    final reviews = MockData.recentReviews;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(game.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      extendBodyBehindAppBar: true,
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 2. Substituímos o SnackBar pela navegação!
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReviewScreen(),
            ),
          );
        },
        backgroundColor: Colors.purpleAccent,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Escrever Resenha', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Image.asset(
                game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações do jogo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(game.genre, style: const TextStyle(color: Colors.purpleAccent, fontSize: 16)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(game.rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Seção de Resenhas
                  const Text(
                    'Últimas Resenhas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista de Resenhas
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(), // Desativa o scroll da lista, o SingleChildScrollView já faz isso
                    shrinkWrap: true,
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ReviewCard(review: reviews[index]),
                      );
                    },
                  ),
                  const SizedBox(height: 60), // Espaço para não ficar atrás do FloatingActionButton
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}