// src/blocs/navigation/navigation_event.dart
abstract class NavigationEvent {}

// Evento disparado quando o usuário clica em uma aba do menu inferior
class TabTappedEvent extends NavigationEvent {
  final int index;
  TabTappedEvent(this.index);
}