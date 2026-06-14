import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_hub/src/ui/pages/catalog/game_details_screen.dart';
import '../../../../data/models/game.dart';
import '../../../../data/models/review_model.dart';
import '../../../widgets/game_card.dart';
import '../../../widgets/review_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Cabeçalho
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 24), // Aumentei o top para não colar no relógio do celular
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GameHub',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Games & RPG Community',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 🔹 Título: Jogos em Destaque
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Text('🔥', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'Jogos em Destaque',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 🔹 StreamBuilder dos Jogos em Destaque (Top 3 Melhores Notas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              height: 180,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('games')
                    .orderBy('rating', descending: true)
                    .limit(3) // Pegamos apenas os 3 melhores
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Nenhum jogo em destaque.', style: TextStyle(color: Colors.white54)),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return Row(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final game = Game(
                        id: doc.id,
                        title: data['title'] ?? 'Sem Título',
                        imageUrl: data['imageUrl'] ?? '',
                        genre: data['genre'] ?? 'Geral',
                        rating: (data['rating'] ?? 0.0).toDouble(),
                      );

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: doc == docs.last ? 0 : 12.0),
                          child: GameCard(
                            game: game,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GameDetailsScreen(game: game)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 🔹 Título: Últimas Resenhas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Últimas Resenhas',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filtro será implementado em breve!')),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // 🔹 StreamBuilder das Últimas Resenhas da Comunidade
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .orderBy('createdAt', descending: true) // Mais recentes primeiro
                .limit(10) // Limita para não pesar a tela inicial
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text('Nenhuma resenha recente.', style: TextStyle(color: Colors.white54)),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const NeverScrollableScrollPhysics(), // SingleChildScrollView já cuida do scroll
                shrinkWrap: true,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  
                  final review = ReviewModel(
                    id: docs[index].id,
                    username: data['username'] ?? 'Usuário',
                    gameTitle: data['gameTitle'] ?? 'Jogo Desconhecido',
                    rating: (data['rating'] ?? 0.0).toDouble(),
                    content: data['content'] ?? '',
                    likes: data['likes'] ?? 0,
                    comments: data['comments'] ?? 0,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ReviewCard(review: review),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}