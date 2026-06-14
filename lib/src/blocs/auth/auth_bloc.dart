// src/blocs/auth/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitialState()) {
    
    // --- LOGIN REQUESTED ---
    on<LoginRequestedEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final user = await _authRepository.login(event.email, event.password);
        if (user != null) {
          emit(AuthenticatedState(user));
        } else {
          emit(AuthFailureState('Usuário ou senha inválidos.'));
          emit(UnauthenticatedState()); // MUDE AQUI
        }
      } catch (e) {
        final cleanError = e.toString().replaceAll('Exception: ', '');
        emit(AuthFailureState(cleanError));
        emit(UnauthenticatedState()); // MUDE AQUI TAMBÉM
      }
    });

    // --- REGISTER REQUESTED ---
    on<RegisterRequestedEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final user = await _authRepository.register(event.username, event.email, event.password);
        if (user != null) {
          emit(AuthenticatedState(user));
        } else {
          emit(AuthFailureState('Não foi possível criar a conta.'));
          emit(UnauthenticatedState()); // MUDE AQUI
        }
      } catch (e) {
        final cleanError = e.toString().replaceAll('Exception: ', '');
        emit(AuthFailureState(cleanError));
        emit(UnauthenticatedState()); // MUDE AQUI TAMBÉM
      }
    });

    // --- LOGOUT REQUESTED ---
    on<LogoutRequestedEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await _authRepository.logout();
        emit(UnauthenticatedState());
      } catch (e) {
        emit(AuthFailureState(e.toString()));
        emit(UnauthenticatedState());
      }
    });

    // --- STATUS CHANGED (STREAM MONITOR) ---
    on<AuthStatusChangedEvent>((event, emit) {
      // Ignora atualizações do Stream enquanto o usuário clica ativamente nos botões de Login/Cadastro
      if (state is AuthLoadingState) return;

      if (event.user != null) {
        emit(AuthenticatedState(event.user!)); 
      } else {
        // Se o estado atual já for de erro ou loading, não força Unauthenticated para não limpar o erro da tela
        if (state is! AuthFailureState && state is! AuthLoadingState) {
          emit(UnauthenticatedState());
        }
      }
    });

    // Escuta o Firebase em tempo real
    _userSubscription = _authRepository.user.listen((user) {
      add(AuthStatusChangedEvent(user));
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}