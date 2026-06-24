import 'package:flutter/material.dart';
import '../../data/models/game.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback? onTap;

  const GameCard({super.key, required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 AQUI ESTÁ A GRANDE MUDANÇA: Lógica de imagem inteligente
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: game.imageUrl.startsWith('http')
                    ? Image.network(
                        game.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                      )
                    : Image.asset(
                        game.imageUrl.isEmpty ? 'assets/images/placeholder.png' : game.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔹 Adicionado o Expanded e overflow no gênero para evitar quebra de layout se o texto for longo
                      Expanded(
                        child: Text(
                          game.genre, 
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4), // Pequeno espaço entre estrela e número
                          Text(game.rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.videogame_asset, color: Colors.white24, size: 40),
      ),
    );
  }
}