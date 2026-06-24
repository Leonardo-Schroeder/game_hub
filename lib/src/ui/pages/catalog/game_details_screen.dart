import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_hub/src/ui/pages/auth/auth_screen.dart';
import 'package:game_hub/src/ui/pages/review/review_screen.dart';
import '../../../data/models/game.dart';
import '../../../data/models/review_model.dart'; 
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
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReviewScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Você precisa estar logado para escrever uma resenha!'),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
          }
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
                  
                  const Text(
                    'Últimas Resenhas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('gameTitle', isEqualTo: game.title) 
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

                      final docs = snapshot.data!.docs.toList();

                      // 🔹 A MÁGICA ACONTECE AQUI: Ordenação à prova de falhas
                      docs.sort((a, b) {
                        final dataA = a.data() as Map<String, dynamic>;
                        final dataB = b.data() as Map<String, dynamic>;
                        
                        // Função interna para descobrir que tipo de data o Firebase nos deu
                        DateTime? parseDate(dynamic dateData) {
                          if (dateData == null) return null;
                          if (dateData is Timestamp) return dateData.toDate(); // Se for Timestamp
                          if (dateData is String) return DateTime.tryParse(dateData); // Se for String
                          return null;
                        }

                        final timeA = parseDate(dataA['createdAt']);
                        final timeB = parseDate(dataB['createdAt']);
                        
                        if (timeA != null && timeB != null) {
                          return timeB.compareTo(timeA); // Descendente (mais novas primeiro)
                        }
                        return 0;
                      });

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          
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
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}