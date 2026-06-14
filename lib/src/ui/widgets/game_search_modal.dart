import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/game.dart'; // Ajuste o caminho se necessário

class GameSearchModal extends StatefulWidget {
  const GameSearchModal({super.key});

  @override
  State<GameSearchModal> createState() => _GameSearchModalState();
}

class _GameSearchModalState extends State<GameSearchModal> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
          ),
          
          const Text('Buscar Jogo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite o nome do jogo...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('games').orderBy('title').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Nenhum jogo cadastrado no sistema ainda.', style: TextStyle(color: Colors.white54)),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final title = (doc['title'] ?? '').toString().toLowerCase();
                  return title.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Nenhum jogo encontrado.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    final game = Game(
                      id: docs[index].id,
                      title: data['title'] ?? 'Sem Título',
                      imageUrl: data['imageUrl'] ?? '',
                      genre: data['genre'] ?? 'Geral',
                      rating: (data['rating'] ?? 0.0).toDouble(),
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: SizedBox( 
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: game.imageUrl.startsWith('http')
                                ? Image.network(
                                    game.imageUrl, 
                                    width: 50, 
                                    height: 50, 
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(Icons.videogame_asset, color: Colors.white54, size: 50),
                                  )
                                : Image.asset(
                                    'assets/images/placeholder.png', 
                                    width: 50, 
                                    height: 50, 
                                    fit: BoxFit.cover, 
                                    errorBuilder: (c, e, s) => const Icon(Icons.videogame_asset, color: Colors.white54, size: 50),
                                  ),
                          ),
                        ), // 🔹 Este era o parênteses que estava faltando!
                        title: Text(game.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children: [
                            Text(game.genre, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 4),
                            Text(game.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.purpleAccent),
                          onPressed: () {
                            Navigator.pop(context, game);
                          },
                        ),
                      ),
                    );
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