import 'dart:typed_data'; // Adicionado para suportar bytes na Web e Mobile
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_hub/src/data/repositories/friends_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:game_hub/src/blocs/review/review.dart';
import 'package:game_hub/src/ui/pages/admin/admin_panel_screen.dart';
import 'package:game_hub/src/blocs/auth/auth_event.dart';
import 'package:game_hub/src/blocs/auth/auth_bloc.dart';
import 'package:game_hub/src/blocs/auth/auth_state.dart';
import 'package:game_hub/src/data/models/game.dart';
import 'package:game_hub/src/data/repositories/review_repository.dart';
import 'package:game_hub/src/data/repositories/library_repository.dart'; 
import 'package:game_hub/src/ui/widgets/manage_friends_modal.dart';
import 'package:game_hub/src/ui/widgets/game_search_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _profileImageBytes; // Substituído de File para Uint8List para suportar a Web
  final ImagePicker _picker = ImagePicker();
  
  final ReviewRepository _reviewRepository = ReviewRepository();
  final LibraryRepository _libraryRepository = LibraryRepository();
  final FriendRepository _friendRepository = FriendRepository(); 

  late Stream<List<Review>> _userReviewsStream;
  late Stream<List<Map<String, dynamic>>> _jogosZeradosStream;
  late Stream<List<Map<String, dynamic>>> _wishlistStream;
  late Stream<List<Map<String, dynamic>>> _friendsStream; 

  @override
  void initState() {
    super.initState();
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    _userReviewsStream = _reviewRepository.getUserReviewsStream(currentUserId);
    _jogosZeradosStream = _libraryRepository.getGamesStream(currentUserId, 'zerado');
    _wishlistStream = _libraryRepository.getGamesStream(currentUserId, 'wishlist');
    _friendsStream = _friendRepository.getFriendsStream(currentUserId); 
  }

  // Novo método _pickImage adaptado para a Web e enviando para o Firebase Storage
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        // 1. Lê a imagem como Bytes (Funciona no Chrome e no Celular perfeitamente)
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        
        // 2. Atualiza a tela imediatamente para o usuário ver a foto
        setState(() {
          _profileImageBytes = imageBytes;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enviando foto para a nuvem...'), backgroundColor: Colors.blueAccent),
          );
        }

        // 3. Prepara o caminho no Firebase Storage
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) return;
        
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${currentUser.uid}.jpg');

        // 4. Faz o upload da imagem usando os Bytes
        await storageRef.putData(imageBytes);

        // 5. Pega o link (URL) da imagem que acabou de subir
        final String downloadUrl = await storageRef.getDownloadURL();

        // 6. Salva a URL no perfil do usuário no Firebase Auth
        await currentUser.updatePhotoURL(downloadUrl);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto salva com sucesso!'), backgroundColor: Colors.purple),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao pegar/upar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar foto.'), backgroundColor: Colors.red),
        );
      }
    }
  }

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

  void _addGameToList(bool isZerado) async {
    final Game? selectedGame = await showModalBottomSheet<Game>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const GameSearchModal(),
        );
      },
    );

    if (selectedGame != null) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return;

      final status = isZerado ? 'zerado' : 'wishlist';

      try {
        await _libraryRepository.addGame(currentUserId, selectedGame, status);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${selectedGame.title} salvo na biblioteca!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar o jogo.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _confirmDeleteReview(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Apagar Resenha', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza que deseja deletar sua resenha permanentemente?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _reviewRepository.deleteReview(reviewId);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resenha apagada!'), backgroundColor: Colors.redAccent));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao apagar resenha.'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Apagar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveGame(String docId) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Remover Jogo', style: TextStyle(color: Colors.white)),
        content: const Text('Deseja remover este jogo da sua lista?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _libraryRepository.removeGame(currentUserId, docId);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jogo removido da lista.'), backgroundColor: Colors.orange));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao remover jogo.'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Remover', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
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

  Widget _buildStreamStatCard(String title, Stream<List<Map<String, dynamic>>> stream, IconData icon, Color iconColor) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final count = (snapshot.data ?? []).length.toString();
        return _buildStatCard(title, count, icon, iconColor);
      }
    );
  }

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
              onPressed: onAddPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), 
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalGameList(Stream<List<Map<String, dynamic>>> stream) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140, 
            child: Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Nenhum jogo adicionado ainda', style: TextStyle(color: Colors.white38, fontSize: 14)),
            ),
          );
        }

        return SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final docId = items[index]['docId'] as String;
              final path = items[index]['imageUrl'] as String;
              
              return GestureDetector(
                onLongPress: () => _confirmRemoveGame(docId),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1E1E1E),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: path.isEmpty 
                    ? const Icon(Icons.videogame_asset, color: Colors.white24, size: 40)
                    : (path.startsWith('http')
                        ? Image.network(path, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white24))
                        : Image.asset(path, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white24))),
                ),
              );
            },
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String username = 'Jogador';
        String email = '';
        bool isAdmin = false; 
        
        // Pega a URL da foto de perfil diretamente da nuvem
        String? photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

        if (state is AuthenticatedState) {
          username = state.user.username;
          email = state.user.email;
          isAdmin = state.user.isAdmin; 
        }

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: StreamBuilder<List<Review>>(
            stream: _userReviewsStream,
            builder: (context, snapshot) {
              
              final List<Review> reviews = snapshot.data ?? [];
              final int totalResenhas = reviews.length;

              return SingleChildScrollView(
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
                                    icon: const Icon(Icons.logout, color: Colors.white),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return BlocListener<AuthBloc, AuthState>(
                                            listener: (context, state) {
                                              if (state is UnauthenticatedState || state is AuthFailureState) {
                                                Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                                              }
                                            },
                                            child: const Center(
                                              child: CircularProgressIndicator(color: Colors.purpleAccent),
                                            ),
                                          );
                                        },
                                      );
                                      context.read<AuthBloc>().add(LogoutRequestedEvent());
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(height: 16),
                                  IconButton(
                                    icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                                    onPressed: _showFriendsModal,
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
                                        color: Colors.white10,
                                      ),
                                      child: _profileImageBytes != null 
                                          // 🔹 Mostra a foto escolhida na hora usando Memory (Bytes)
                                          ? ClipOval(child: Image.memory(_profileImageBytes!, fit: BoxFit.cover, width: 80, height: 80))
                                          // 🔹 Se não, tenta baixar a foto que já está no Firebase
                                          : (photoUrl != null && photoUrl.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    photoUrl, 
                                                    fit: BoxFit.cover, 
                                                    width: 80, 
                                                    height: 80,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40, color: Colors.white30),
                                                  )
                                                )
                                              // 🔹 Se não tem foto nenhuma, mostra o ícone de avatar padrão
                                              : const Icon(Icons.person, size: 40, color: Colors.white30)),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(username, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                    
                                    if (isAdmin) ...[
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Acesso concedido! Carregando Painel...'),
                                              backgroundColor: Colors.redAccent,
                                              duration: Duration(seconds: 1), 
                                            ),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const AdminPanelScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.admin_panel_settings, size: 16, color: Colors.white),
                                        label: const Text('Painel de Controle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ],
                                    
                                    const SizedBox(height: 12),
                                    Wrap(
                                      children: [
                                        StreamBuilder<List<Map<String, dynamic>>>(
                                          stream: _jogosZeradosStream,
                                          builder: (context, snap) => Text('${(snap.data ?? []).length} ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                        const Text('jogos  ', style: TextStyle(color: Colors.white70)),
                                        
                                        Text('$totalResenhas ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        const Text('resenhas  ', style: TextStyle(color: Colors.white70)),
                                        
                                        StreamBuilder<List<Map<String, dynamic>>>(
                                          stream: _friendsStream,
                                          builder: (context, snap) => Text(
                                            '${(snap.data ?? []).length} ', 
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                          ),
                                        ),
                                        const Text('amigos', style: TextStyle(color: Colors.white70)),
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
                          Expanded(child: _buildStreamStatCard('Zerados', _jogosZeradosStream, Icons.access_time, Colors.purpleAccent)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStreamStatCard('Wishlist', _wishlistStream, Icons.favorite_border, Colors.pinkAccent)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Resenhas', totalResenhas.toString(), Icons.edit_outlined, Colors.amber)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSectionHeader(
                      '🏆', 
                      'Jogos Zerados', 
                      showAddIcon: true, 
                      onAddPressed: () => _addGameToList(true),
                    ),
                    _buildHorizontalGameList(_jogosZeradosStream),
                    
                    const SizedBox(height: 8),
                    
                    _buildSectionHeader(
                      '🤍', 
                      'Lista de Desejos', 
                      showAddIcon: true,
                      onAddPressed: () => _addGameToList(false),
                    ),
                    _buildHorizontalGameList(_wishlistStream),
                    
                    const SizedBox(height: 8),
                    _buildSectionHeader('✍️', 'Histórico de Resenhas'),
                    
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: Colors.purpleAccent),
                      ))
                    else if (reviews.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Você ainda não escreveu nenhuma resenha.', style: TextStyle(color: Colors.white54)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true, 
                        physics: const NeverScrollableScrollPhysics(), 
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                review.gameTitle, 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  review.content, 
                                  maxLines: 2, 
                                  overflow: TextOverflow.ellipsis, 
                                  style: const TextStyle(color: Colors.white70)
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    review.rating.toStringAsFixed(1), 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _confirmDeleteReview(review.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40), 
                  ],
                ),
              );
            }
          ),
        );
      },
    );
  }
}