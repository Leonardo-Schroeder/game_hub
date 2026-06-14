abstract class CatalogState {}

class CatalogLoadingState extends CatalogState {}

class CatalogLoadedState extends CatalogState {
  final List<Map<String, dynamic>> games;
  CatalogLoadedState(this.games);
}

class CatalogErrorState extends CatalogState {
  final String message;
  CatalogErrorState(this.message);
}