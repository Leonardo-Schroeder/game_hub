// src/blocs/navigation/navigation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  // Define o estado inicial apontando para a aba 0 (Dashboard)
  NavigationBloc() : super(NavigationState(0)) {
    
    // Quando o evento TabTappedEvent chegar, mudamos o estado com o novo índice
    on<TabTappedEvent>((event, emit) {
      emit(NavigationState(event.index));
    });
  }
}