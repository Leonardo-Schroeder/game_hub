import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GameHub', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)), // [cite: 16]
            Text('Games & RPG Community', style: TextStyle(fontSize: 12, color: Colors.grey)), // [cite: 17]
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🔥 Jogos em Destaque', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // [cite: 18]
              const SizedBox(height: 16),
              // Carrossel Horizontal
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildGameCard('Cyberpunk 2077', Colors.yellow[700]!), // [cite: 19]
                    const SizedBox(width: 16),
                    _buildGameCard('Red Dead Redemption II', Colors.red[800]!), // [cite: 20]
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('💬 Últimas Resenhas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // [cite: 21]
                  Icon(Icons.filter_list),
                ],
              ),
              const SizedBox(height: 16),
              // Lista de Resenhas Vertical
              _buildReviewCard(
                'RPGMaster', // [cite: 22]
                'Hollow Knight', // [cite: 23]
                'Uma obra-prima absoluta! A atmosfera sombria e a jogabilidade fluida fazem deste um dos melhores metroidvanias já criados.', // [cite: 24, 25, 26]
                5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget ajudante para criar os cards de jogos
  Widget _buildGameCard(String title, Color color) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
    );
  }

  // Widget ajudante para criar as resenhas
  Widget _buildReviewCard(String user, String game, String review, int rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(game, style: const TextStyle(color: Colors.purpleAccent, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Row(children: List.generate(rating, (index) => const Icon(Icons.star, color: Colors.amber, size: 16))), // [cite: 29]
            ],
          ),
          const SizedBox(height: 12),
          Text(review, style: const TextStyle(color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }
}