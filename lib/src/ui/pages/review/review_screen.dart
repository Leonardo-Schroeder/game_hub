import 'package:flutter/material.dart';
import 'package:game_hub/src/ui/widgets/game_search_modal.dart';
import '../../../models/review.dart';
import '../../../models/game.dart'; // Precisamos importar o Game model
import '../../widgets/game_selector_card.dart';
import '../home/home_screen.dart';
import 'review_confirmation_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // --- Variáveis de Estado ---
  Game?
  _selectedGame; // Agora a tela sabe qual jogo foi escolhido (Começa nulo)
  double _rating = 4.5;
  bool _recommend = true;
  String _platform = 'PC';
  bool _hasSpoilers = false;
  bool _agreedToRules = false;

  final TextEditingController _reviewController = TextEditingController();

  void _openGameSelector() async {
    final Game? gamePegoDaLista = await showModalBottomSheet<Game>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Deixa transparente pro modal desenhar a borda
      builder: (BuildContext context) {
        return Padding(
          // Esse padding faz o modal subir se o teclado aparecer!
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const GameSearchModal(),
        );
      },
    );

    if (gamePegoDaLista != null) {
      setState(() {
        _selectedGame = gamePegoDaLista;
      });
    }
  }

  void _submitReview() {
    // Validação: Verificamos se o jogo foi escolhido!
    if (_selectedGame == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o jogo que deseja avaliar!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_agreedToRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar as regras!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final novaResenha = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: 'Leonardo',
      gameTitle:
          _selectedGame!.title, // Usando o título do jogo escolhido de verdade!
      rating: _rating,
      content: _reviewController.text.isEmpty
          ? 'Sem comentários.'
          : _reviewController.text,
      likes: 0,
      comments: 0,
    );

    debugPrint(
      'Resenha salva: ${novaResenha.gameTitle} - Nota: ${novaResenha.rating}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReviewConfirmationScreen()),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 24.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Escrever Resenha',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Selecione o jogo'),
            // Passamos o _selectedGame e conectamos a função _openGameSelector
            GameSelectorCard(
              selectedGame: _selectedGame,
              isMinimal: false,
              onTap: _openGameSelector,
            ),

            _buildSectionTitle('Sua avaliação'),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        _rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 50,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.grey[800],
                    label: _rating.toStringAsFixed(1),
                    onChanged: (val) => setState(() => _rating = val),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('Sua experiência'),
            TextFormField(
              controller: _reviewController,
              maxLines: 6,
              maxLength: 500,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Compartilhe sua jornada, o que mais gostou...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterStyle: const TextStyle(color: Colors.white54),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Mínimo 50 caracteres',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),

            _buildSectionTitle('Você recomenda?'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _recommend = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _recommend
                            ? Colors.green.withValues(alpha: 0.15)
                            : const Color(0xFF1E1E1E),
                        border: Border.all(
                          color: _recommend ? Colors.green : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            color: _recommend ? Colors.green : Colors.white54,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sim',
                            style: TextStyle(
                              color: _recommend ? Colors.green : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _recommend = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: !_recommend
                            ? Colors.redAccent.withValues(alpha: 0.15)
                            : const Color(0xFF1E1E1E),
                        border: Border.all(
                          color: !_recommend
                              ? Colors.redAccent
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.thumb_down_alt_outlined,
                            color: !_recommend
                                ? Colors.redAccent
                                : Colors.white54,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Não',
                            style: TextStyle(
                              color: !_recommend
                                  ? Colors.redAccent
                                  : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            _buildSectionTitle('Plataforma jogada'),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: RadioGroup<String>(
                groupValue: _platform,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _platform = val);
                  }
                },
                child: Column(
                  children: ['PC', 'Console', 'Mobile']
                      .map(
                        (p) => RadioListTile<String>(
                          title: Text(
                            p,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: p,
                          activeColor: Colors.purpleAccent,
                          // Removemos o groupValue e o onChanged que ficavam aqui!
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Contém spoilers?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Oculte detalhes da história',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: _hasSpoilers,
              activeThumbColor: Colors.purpleAccent,
              onChanged: (val) => setState(() => _hasSpoilers = val),
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Declaro que esta resenha segue as regras da comunidade',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              value: _agreedToRules,
              activeColor: Colors.purpleAccent,
              checkColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              onChanged: (val) => setState(() => _agreedToRules = val!),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Publicar Resenha',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
