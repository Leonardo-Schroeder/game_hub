import 'package:flutter/material.dart';

class ManageFriendsModal extends StatefulWidget {
  const ManageFriendsModal({super.key});

  @override
  State<ManageFriendsModal> createState() => _ManageFriendsModalState();
}

class _ManageFriendsModalState extends State<ManageFriendsModal> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _friends = ['Alex', 'PlayerOne', 'Sam_RPG'];

  void _addFriend() {
    final newFriend = _searchController.text.trim();
    if (newFriend.isNotEmpty) {
      setState(() {
        _friends.insert(0, newFriend); // Adiciona no topo da lista
        _searchController.clear(); // Limpa o campo
      });
      // Fecha o teclado após adicionar
      FocusScope.of(context).unfocus();
    }
  }

  void _removeFriend(int index) {
    setState(() {
      _friends.removeAt(index);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            'Gerenciar Amigos',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // --- BARRA DE ADICIONAR ---
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'E-mail ou Username...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.person_add_alt_1, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botão Adicionar
              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D00FF), Color(0xFFE100FF)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _addFriend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Sua Lista',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // --- LISTA DE AMIGOS ---
          Expanded(
            child: _friends.isEmpty
                ? const Center(
                    child: Text('Você ainda não adicionou nenhum amigo.', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friendName = _friends[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.withValues(alpha: 0.2),
                            child: const Icon(Icons.person, color: Colors.purpleAccent),
                          ),
                          title: Text(friendName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                            onPressed: () => _removeFriend(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}