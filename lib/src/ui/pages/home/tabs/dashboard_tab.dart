import 'package:flutter/material.dart';
import '../../../../models/mock_data.dart';
import '../../../widgets/game_card.dart';
import '../../../widgets/review_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos SingleChildScrollView + Column para montar o layout vertical completo da tela
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com Gradiente (Igual ao mockup)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)], // Purple to Deep Pink
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

          // Seção 1: Jogos em Destaque (3 colunas iguais)
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
          
          // Nova estrutura usando Row + Expanded
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              height: 180, // Altura ajustada para manter a proporção dos cards menores
              child: Row(
                children: [
                  Expanded(child: GameCard(game: MockData.featuredGames[0])),
                  const SizedBox(width: 12), // Espaço entre esquerda e meio
                  Expanded(child: GameCard(game: MockData.featuredGames[1])),
                  const SizedBox(width: 12), // Espaço entre meio e direita
                  Expanded(child: GameCard(game: MockData.featuredGames[2])),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Seção 2: Últimas Resenhas (Lista Vertical)
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
          
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: MockData.recentReviews.length,
            itemBuilder: (context, index) {
              return ReviewCard(review: MockData.recentReviews[index]);
            },
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}