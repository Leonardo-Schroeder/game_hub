import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_hub/src/data/repositories/admin_repository.dart';
import 'package:game_hub/src/data/repositories/review_repository.dart'; // 🔹 Importamos o repositório que realmente apaga!

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final AdminRepository _adminRepository = AdminRepository();
  final ReviewRepository _reviewRepository = ReviewRepository(); // 🔹 Instanciamos aqui
  
  // Controladores para o formulário de cadastro de jogos
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageController = TextEditingController();
  final _categoryController = TextEditingController();
  final _ratingController = TextEditingController(); 
  bool _isSavingGame = false;

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    _ratingController.dispose(); 
    super.dispose();
  }

  void _saveGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSavingGame = true);

    try {
      double rating = double.tryParse(_ratingController.text.trim().replaceAll(',', '.')) ?? 0.0;

      await _adminRepository.addNewGame(
        _titleController.text.trim(),
        _imageController.text.trim(),
        _categoryController.text.trim(), 
        rating,                          
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogo cadastrado com sucesso globalmente!'), backgroundColor: Colors.green),
        );
        _titleController.clear();
        _imageController.clear();
        _categoryController.clear();
        _ratingController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar jogo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingGame = false);
    }
  }

  void _confirmDeleteReview(String reviewId, String gameTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Moderar Resenha', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja apagar permanentemente a resenha do jogo "$gameTitle"? Isso removerá o comentário do feed.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha o modal
              try {
                // 🔹 AQUI ESTÁ A MÁGICA: Usamos a mesma função de apagar que já funciona no Perfil!
                await _reviewRepository.deleteReview(reviewId);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resenha excluída pelo Administrador.'), backgroundColor: Colors.orange),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao deletar resenha.'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Apagar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Painel do Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.rate_review), text: 'Moderar Resenhas'),
              Tab(icon: Icon(Icons.add_to_photos), text: 'Cadastrar Jogos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 🔹 ABA 1: LISTA E MODERAÇÃO DE RESENHAS
            StreamBuilder<QuerySnapshot>(
              stream: _adminRepository.getAllReviewsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma resenha publicada no sistema.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final reviewId = docs[index].id;
                    final gameTitle = data['gameTitle'] ?? 'Jogo Desconhecido';
                    final content = data['content'] ?? '';
                    final rating = (data['rating'] ?? 0.0).toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(gameTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(rating, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(content, style: const TextStyle(color: Colors.white70)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDeleteReview(reviewId, gameTitle), // 🔹 Ajustamos os parâmetros
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // 🔹 ABA 2: FORMULÁRIO DE CADASTRO DE JOGOS
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Adicionar Novo Jogo ao Banco', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Este jogo ficará disponível globalmente na busca para todos os usuários.', style: TextStyle(color: Colors.white38, fontSize: 13)),
                    const SizedBox(height: 24),
                    
                    // Input Título
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Título do Jogo', Icons.sports_esports),
                      validator: (v) => v == null || v.isEmpty ? 'Insira o nome do jogo' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Input URL da Imagem
                    TextFormField(
                      controller: _imageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('URL da Imagem da Capa', Icons.image),
                      validator: (v) => v == null || v.isEmpty ? 'Insira o link da imagem' : null,
                    ),
                    const SizedBox(height: 16),

                    // Input Categoria/Gênero
                    TextFormField(
                      controller: _categoryController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Gênero (Ex: RPG, Ação)', Icons.category),
                      validator: (v) => v == null || v.isEmpty ? 'Insira a categoria' : null,
                    ),
                    const SizedBox(height: 16),

                    // Input Nota (Rating)
                    TextFormField(
                      controller: _ratingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Nota Inicial (Ex: 4.8)', Icons.star),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Insira uma nota';
                        if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Digite um número válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botão Enviar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSavingGame ? null : _saveGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSavingGame
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Cadastrar Jogo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
    );
  }
}