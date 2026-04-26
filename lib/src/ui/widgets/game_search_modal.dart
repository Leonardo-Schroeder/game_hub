import 'package:flutter/material.dart';
import 'package:game_hub/src/models/mock_data.dart';

class GameSearchModal extends StatefulWidget {
  const GameSearchModal({super.key});

  @override
  State<GameSearchModal> createState() => _GameSearchModalState();
}

class _GameSearchModalState extends State<GameSearchModal> {
  String _searchQuery = ''; // Guarda o que o usuário está digitando

  @override
  Widget build(BuildContext context) {
    // Filtra os jogos baseado no que foi digitado (ignorando maiúsculas/minúsculas)
    final filteredGames = MockData.catalogGames.where((game) {
      return game.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Ocupa 75% da tela
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buscar Jogo',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // --- BARRA DE PESQUISA ---
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value; // Atualiza a tela a cada letra digitada
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Digite o nome do jogo...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF121212), // Fundo mais escuro para o input
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // --- LISTA DE JOGOS FILTRADOS ---
          Expanded(
            child: filteredGames.isEmpty
                ? const Center(
                    child: Text('Nenhum jogo encontrado.', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    itemCount: filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = filteredGames[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            game.imageUrl, 
                            width: 50, 
                            height: 50, 
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(width: 50, height: 50, color: Colors.grey[800], child: const Icon(Icons.videogame_asset, color: Colors.white54)),
                          ),
                        ),
                        title: Text(game.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(game.genre, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          // Retorna o jogo selecionado e fecha o modal
                          Navigator.pop(context, game);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}