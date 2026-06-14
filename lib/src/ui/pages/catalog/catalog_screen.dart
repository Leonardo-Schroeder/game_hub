import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_hub/src/ui/pages/catalog/game_details_screen.dart';

// 🔹 Importações do BLoC em vez do Firestore
import 'package:game_hub/src/blocs/catalog/catalog_bloc.dart';
import '../../widgets/game_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _searchQuery = ''; 
  Set<String> _selectedFilters = {}; 
  final List<String> _availableFilters = ['RPG', 'Indie', 'Plataforma', 'Ação', 'Simulação', 'Metroidvania'];

  @override
  void initState() {
    super.initState();
    // 🔹 Dispara o evento para o BLoC buscar os dados quando a tela abre
    context.read<CatalogBloc>().add(LoadCatalogEvent());
  }

  void _showFilterModal() {
    Set<String> tempFilters = Set.from(_selectedFilters);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrar por Gênero',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() => tempFilters.clear());
                        },
                        child: const Text('Limpar', style: TextStyle(color: Colors.white54)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
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
                        selectedColor: Colors.purple.withValues(alpha: 0.5),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
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

  Widget _buildHeader() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: statusBarHeight + 16, left: 24, right: 24, bottom: 16),
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
            backgroundColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.15)),
            elevation: WidgetStateProperty.all(0),
            textStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
            hintStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white54)),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(int resultCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedFilters.isEmpty && _searchQuery.isEmpty
                ? 'Todos os Jogos' 
                : '$resultCount Resultados',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _buildHeader(),
          
          // 🔹 Substituímos o StreamBuilder pelo BlocBuilder
          Expanded(
            child: BlocBuilder<CatalogBloc, CatalogState>(
              builder: (context, state) {
                
                if (state is CatalogLoadingState) {
                  return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                }

                if (state is CatalogErrorState) {
                  return Center(
                    child: Text(state.message, style: const TextStyle(color: Colors.redAccent)),
                  );
                }

                if (state is CatalogLoadedState) {
                  final allGames = state.games;

                  if (allGames.isEmpty) {
                    return const Center(
                      child: Text('Nenhum jogo no catálogo.', style: TextStyle(color: Colors.white54)),
                    );
                  }

                  // 2. Aplica os SEUS filtros perfeitamente em cima da lista do BLoC
                  final filteredGames = allGames.where((game) {
                    final matchesSearch = _searchQuery.isEmpty || game.title.toLowerCase().contains(_searchQuery);
                    final matchesFilter = _selectedFilters.isEmpty || _selectedFilters.any((filter) => game.genre.contains(filter));
                    return matchesSearch && matchesFilter;
                  }).toList();

                  return Column(
                    children: [
                      _buildFilterBar(filteredGames.length), 
                      
                      Expanded(
                        child: filteredGames.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum jogo encontrado com esses filtros.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: filteredGames.length,
                                itemBuilder: (ctx, i) {
                                  final game = filteredGames[i];
                                  return GameCard(
                                    game: game,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GameDetailsScreen(game: game),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }
                
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}