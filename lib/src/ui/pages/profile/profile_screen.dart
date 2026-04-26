import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/game.dart'; // Importando o modelo Game
import '../../widgets/manage_friends_modal.dart';
import '../../widgets/game_search_modal.dart'; // Importando o modal de busca que usamos na resenha

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Transformando as listas de jogos em estado para atualizar a tela!
  final List<String> _jogosZerados = [
    'assets/images/hades.jpg',
    'assets/images/god_of_war.jpg',
    'assets/images/hollow_knight.webp',
    'assets/images/celeste.webp',
  ];

  final List<String> _wishlist = [
    'assets/images/red.jpg',
    'assets/images/stardew.jpg',
  ];

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto atualizada com sucesso!'), backgroundColor: Colors.purple),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao pegar imagem: $e');
    }
  }

  // --- Modal de Amigos (Apenas para o botão superior) ---
  void _showFriendsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const ManageFriendsModal(),
        );
      },
    );
  }

  // --- Novo Modal de Buscar Jogo (Para as listas inferiores) ---
  void _addGameToList(bool isZerado) async {
    final Game? selectedGame = await showModalBottomSheet<Game>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const GameSearchModal(), // Reutilizando a pesquisa da resenha!
        );
      },
    );

    if (selectedGame != null) {
      setState(() {
        if (isZerado) {
          _jogosZerados.insert(0, selectedGame.imageUrl); // Adiciona no começo da lista
        } else {
          _wishlist.insert(0, selectedGame.imageUrl);
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedGame.title} adicionado!'), backgroundColor: Colors.purple),
        );
      }
    }
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Agora recebe uma função customizada no 'onAddPressed'
  Widget _buildSectionHeader(String emoji, String title, {bool showAddIcon = false, VoidCallback? onAddPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (showAddIcon)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white54),
              onPressed: onAddPressed, // Função disparada varia de acordo com a lista
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), 
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalGameList(List<String> imagePaths) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF1E1E1E),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              imagePaths[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.videogame_asset, color: Colors.white24, size: 40),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: statusBarHeight + 16, left: 24, right: 24, bottom: 32),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meu Perfil',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.white),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(height: 16),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _showFriendsModal, // Mantivemos Amigos aqui no topo!
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                image: DecorationImage(
                                  image: _profileImage != null 
                                      ? FileImage(_profileImage!) as ImageProvider
                                      : const AssetImage('assets/images/stardew.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.purpleAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RPGMaster', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Explorador de mundos', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            SizedBox(height: 12),
                            Wrap(
                              children: [
                                Text('24 ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('jogos   ', style: TextStyle(color: Colors.white70)),
                                Text('18 ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('resenhas   ', style: TextStyle(color: Colors.white70)),
                                Text('12 ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('amigos', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('Zerados', '24', Icons.access_time, Colors.purpleAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Wishlist', '8', Icons.favorite_border, Colors.pinkAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Resenhas', '18', Icons.edit_outlined, Colors.amber)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Usando a nova função conectada ao Modal de Busca
            _buildSectionHeader(
              '🏆', 
              'Jogos Zerados', 
              showAddIcon: true, 
              onAddPressed: () => _addGameToList(true), // true = Zerado
            ),
            _buildHorizontalGameList(_jogosZerados), // Passa a variável de estado
            
            const SizedBox(height: 8),
            
            _buildSectionHeader(
              '🤍', 
              'Lista de Desejos', 
              showAddIcon: true,
              onAddPressed: () => _addGameToList(false), // false = Wishlist
            ),
            _buildHorizontalGameList(_wishlist), // Passa a variável de estado
            
            const SizedBox(height: 8),
            _buildSectionHeader('✍️', 'Histórico de Resenhas'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Suas resenhas aparecerão aqui', style: TextStyle(color: Colors.white54)),
              ),
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }
}