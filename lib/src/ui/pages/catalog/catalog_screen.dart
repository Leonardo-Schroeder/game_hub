import 'package:flutter/material.dart';
import '../../../models/game.dart';
import '../../widgets/game_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // --- Variáveis de Estado ---
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  
  Set<String> _selectedFilters = {}; 
  final List<String> _availableFilters = ['RPG', 'Indie', 'Plataforma', 'Ação', 'Simulação', 'Metroidvania'];

  // Dados falsos temporários
  final List<Game> _mockGames = [
    const Game(id: '1', title: 'Hollow Knight', genre: 'Metroidvania', rating: 4.9, imageUrl: ''),
    const Game(id: '2', title: 'Stardew Valley', genre: 'Simulação', rating: 4.8, imageUrl: ''),
    const Game(id: '3', title: 'Cyberpunk 2077', genre: 'RPG', rating: 4.5, imageUrl: ''),
    const Game(id: '4', title: 'God of War', genre: 'Ação', rating: 4.9, imageUrl: ''),
    const Game(id: '5', title: 'Celeste', genre: 'Plataforma/Indie', rating: 4.8, imageUrl: ''),
    const Game(id: '6', title: 'Hades', genre: 'Ação/Indie', rating: 4.9, imageUrl: ''),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Lógica de filtragem dos dados
  List<Game> get _filteredGames {
    if (_selectedFilters.isEmpty) return _mockGames;
    return _mockGames.where((game) {
      return _selectedFilters.any((filter) => game.genre.contains(filter));
    }).toList();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 && !_isLoadingMore) {
      _fetchMoreGames();
    }
  }

  Future<void> _fetchMoreGames() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoadingMore = false);
  }

  // --- Função que abre a "Telinha" (Bottom Sheet) ---
  void _showFilterModal() {
    // Criamos uma cópia temporária para o usuário brincar no modal sem afetar a tela atrás imediatamente
    Set<String> tempFilters = Set.from(_selectedFilters);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo do modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // StatefulBuilder é necessário para atualizar a tela DE DENTRO do modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ocupa apenas o tamanho necessário
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrar por Gênero',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          // Limpa tudo
                          setModalState(() => tempFilters.clear());
                        },
                        child: const Text('Limpar', style: TextStyle(color: Colors.white54)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Wrap organiza os botões e os joga para a linha de baixo se não couberem (quebra de linha automática)
                  Wrap(
                    spacing: 8.0, // Espaço horizontal entre eles
                    runSpacing: 8.0, // Espaço vertical entre as linhas
                    children: _availableFilters.map((filter) {
                      final isSelected = tempFilters.contains(filter);
                      return FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              tempFilters.add(filter);
                            } else {
                              tempFilters.remove(filter);
                            }
                          });
                        },
                        showCheckmark: true,
                        checkmarkColor: Colors.white,
                        selectedColor: Colors.purple.withOpacity(0.5),
                        backgroundColor: const Color(0xFF121212),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? Colors.purpleAccent : Colors.transparent),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botão de Aplicar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Salva os filtros temporários no estado oficial da tela e fecha o modal
                        setState(() {
                          _selectedFilters = tempFilters;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Aplicar Filtros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI Builders ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catálogo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          SearchBar(
            hintText: 'Buscar jogos...',
            leading: const Icon(Icons.search, color: Colors.white54),
            backgroundColor: WidgetStateProperty.all(Colors.white.withOpacity(0.15)),
            elevation: WidgetStateProperty.all(0),
            textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
            hintStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white54)),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedFilters.isEmpty 
                ? 'Todos os Jogos' 
                : '${_filteredGames.length} Resultados',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          
          // O Botão que chama o modal
          OutlinedButton.icon(
            onPressed: _showFilterModal,
            icon: const Icon(Icons.tune, color: Colors.purpleAccent, size: 18),
            label: Text(
              _selectedFilters.isEmpty 
                  ? 'Filtros' 
                  : 'Filtros (${_selectedFilters.length})', 
              style: const TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.purpleAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamesToDisplay = _filteredGames;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(), // Substituímos a lista horizontal por esta barra com o botão!
          
          Expanded(
            child: gamesToDisplay.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum jogo encontrado.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // removemos o padding superior pois a barra de filtros já dá o espaçamento
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: gamesToDisplay.length,
                    itemBuilder: (ctx, i) => GameCard(game: gamesToDisplay[i]),
                  ),
          ),
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            ),
        ],
      ),
    );
  }
}