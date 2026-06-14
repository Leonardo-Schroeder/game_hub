// Local: src/blocs/catalog/catalog_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/game.dart';
import '../../data/repositories/catalog_repository.dart';

// --- EVENTOS ---
abstract class CatalogEvent {}

class LoadCatalogEvent extends CatalogEvent {}

class UpdateCatalogEvent extends CatalogEvent {
  final List<Game> games;
  UpdateCatalogEvent(this.games);
}

// --- ESTADOS ---
abstract class CatalogState {}

class CatalogLoadingState extends CatalogState {}

class CatalogLoadedState extends CatalogState {
  final List<Game> games;
  CatalogLoadedState(this.games);
}

class CatalogErrorState extends CatalogState {
  final String message;
  CatalogErrorState(this.message);
}

// --- BLOC ---
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final CatalogRepository repository;
  StreamSubscription? _catalogSubscription;

  CatalogBloc({required this.repository}) : super(CatalogLoadingState()) {
    
    on<LoadCatalogEvent>((event, emit) {
      emit(CatalogLoadingState());
      
      _catalogSubscription?.cancel();
      
      _catalogSubscription = repository.getCatalogStream().listen(
        (gamesData) {
          add(UpdateCatalogEvent(gamesData));
        },
        onError: (error) {
          emit(CatalogErrorState('Erro ao carregar catálogo: $error'));
        },
      );
    });

    on<UpdateCatalogEvent>((event, emit) {
      emit(CatalogLoadedState(event.games));
    });
  }

  @override
  Future<void> close() {
    _catalogSubscription?.cancel();
    return super.close();
  }
}