import 'package:flutter/material.dart';
import 'package:game_hub/src/data/models/game.dart';

class GameSelectorCard extends StatelessWidget {
  final Game? selectedGame; // Recebe o modelo do jogo. Se for null, mostra estado vazio.
  final VoidCallback onTap;
  final bool isMinimal; // Controla se é a versão completa ou a enxuta

  const GameSelectorCard({
    super.key,
    required this.selectedGame,
    required this.onTap,
    this.isMinimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMinimal ? 12.0 : 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // --- IMAGEM DO JOGO ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: selectedGame != null
                  ? Image.asset(
                      selectedGame!.imageUrl,
                      width: isMinimal ? 40 : 56,
                      height: isMinimal ? 40 : 56,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 16),

            // --- TEXTOS ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedGame?.title ?? 'Selecionar um jogo',
                    style: TextStyle(
                      color: selectedGame != null ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: isMinimal ? 16 : 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Só mostra o subtítulo se NÃO for a versão minimalista e tiver um jogo selecionado
                  if (!isMinimal && selectedGame != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${selectedGame!.genre} • 202X', // Como não temos ano no model, coloquei um fixo provisório
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),

            // --- ÍCONE DA DIREITA ---
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: isMinimal ? 40 : 56,
      height: isMinimal ? 40 : 56,
      color: Colors.grey[800],
      child: Icon(Icons.videogame_asset, color: Colors.white54, size: isMinimal ? 20 : 28),
    );
  }
}