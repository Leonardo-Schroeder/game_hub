import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_hub/src/data/repositories/friends_repository.dart';

class ManageFriendsModal extends StatefulWidget {
  const ManageFriendsModal({super.key});

  @override
  State<ManageFriendsModal> createState() => _ManageFriendsModalState();
}

class _ManageFriendsModalState extends State<ManageFriendsModal> {
  final FriendRepository _friendRepository = FriendRepository();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  void _onSearchChanged(String value) async {
    setState(() {
      _searchQuery = value.trim();
      _isSearching = true;
    });

    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final results = await _friendRepository.searchUsers(_currentUserId, _searchQuery);
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Tracinho superior
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
          ),
          
          const Text('Amigos da Comunidade', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // 🔹 Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar usuários por nome...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 Lista Dinâmica (Mostra Resultado da Busca OU a Lista de Amigos)
          Expanded(
            child: _searchQuery.isNotEmpty 
                ? _buildSearchResults() // Mostra a busca se digitou algo
                : _buildMyFriends(),    // Mostra os amigos se a barra estiver vazia
          ),
        ],
      ),
    );
  }

  // 🔹 WIDGET: Lista de Resultados da Busca
  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text('Nenhum usuário encontrado.', style: TextStyle(color: Colors.white54)));
    }

    // Ouve a lista de amigos atuais para saber se o botão deve ser "Adicionar" ou "Remover"
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _friendRepository.getFriendsStream(_currentUserId),
      builder: (context, snapshot) {
        final myFriendsIds = (snapshot.data ?? []).map((f) => f['uid']).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final user = _searchResults[index];
            final isFriend = myFriendsIds.contains(user['uid']);

            return _buildUserTile(user, isFriend);
          },
        );
      }
    );
  }

  // 🔹 WIDGET: Lista de Amigos Atuais
  Widget _buildMyFriends() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _friendRepository.getFriendsStream(_currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
        }

        final friends = snapshot.data ?? [];

        if (friends.isEmpty) {
          return const Center(
            child: Text('Você ainda não adicionou nenhum amigo.\nBusque pelo nome acima!', 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return _buildUserTile(friend, true); // Como está na lista de amigos, isFriend é true
          },
        );
      },
    );
  }

  // 🔹 WIDGET: O visual de cada "linha" de usuário
  Widget _buildUserTile(Map<String, dynamic> user, bool isFriend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purpleAccent.withOpacity(0.2),
          child: const Icon(Icons.person, color: Colors.purpleAccent),
        ),
        title: Text(user['username'] ?? 'Usuário', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(user['email'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: isFriend
            // Botão de Remover (Vermelho)
            ? IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                onPressed: () => _friendRepository.removeFriend(_currentUserId, user['uid']),
              )
            // Botão de Adicionar (Verde)
            : IconButton(
                icon: const Icon(Icons.person_add, color: Colors.greenAccent),
                onPressed: () => _friendRepository.addFriend(_currentUserId, user),
              ),
      ),
    );
  }
}