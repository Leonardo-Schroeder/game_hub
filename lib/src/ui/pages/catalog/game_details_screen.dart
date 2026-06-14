import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_hub/src/ui/pages/review/review_screen.dart';
import '../../../data/models/game.dart';
import '../../../data/models/review_model.dart'; // 🔹 Importamos o modelo ao invés do mock
import '../../widgets/review_card.dart';

class GameDetailsScreen extends StatelessWidget {
  final Game game;

  const GameDetailsScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(game.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
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
            // 🔹 Ajuste para carregar imagens da Web (Network) ou Locais (Asset)
            SizedBox(
              width: double.infinity,
              height: 300,
              child: game.imageUrl.startsWith('http')
                  ? Image.network(
                      game.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800], 
                        child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                      ),
                    )
                  : Image.asset(
                      game.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800], 
                        child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                      ),
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
                          Text(game.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  
                  // 🔹 StreamBuilder para buscar as resenhas SÓ DESTE JOGO no Firebase
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('gameTitle', isEqualTo: game.title) // O "Segredo" do filtro
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(
                            child: Text(
                              'Ainda não há resenhas para este jogo.\nSeja o primeiro a avaliar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(), // Mantém o scroll fluido no SingleChildScrollView
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          
                          // Mapeando do Banco para o Modelo
                          final review = ReviewModel(
                            id: docs[index].id,
                            username: data['username'] ?? 'Usuário',
                            gameTitle: data['gameTitle'] ?? game.title,
                            rating: (data['rating'] ?? 0.0).toDouble(),
                            content: data['content'] ?? '',
                            likes: data['likes'] ?? 0,
                            comments: data['comments'] ?? 0,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ReviewCard(review: review),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Espaço para não esconder nada debaixo do botão
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}