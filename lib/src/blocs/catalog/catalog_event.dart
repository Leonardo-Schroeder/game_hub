abstract class CatalogEvent {}

// Disparado quando a tela abre (no initState)
class LoadCatalogEvent extends CatalogEvent {}

// Disparado internamente pelo BLoC quando o Firebase envia uma atualização
class UpdateCatalogEvent extends CatalogEvent {
  final List<Map<String, dynamic>> games;
  UpdateCatalogEvent(this.games);
}