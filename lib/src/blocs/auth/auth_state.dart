// src/blocs/auth/auth_state.dart
import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}
class AuthLoadingState extends AuthState {}

// Estado quando o usuário está autenticado no Firebase
class AuthenticatedState extends AuthState {
  final UserModel user;
  AuthenticatedState(this.user);
}

// Estado quando o usuário NÃO está logado
class UnauthenticatedState extends AuthState {}

// Estado caso dê erro no login (ex: senha errada)
class AuthFailureState extends AuthState {
  final String errorMessage;
  AuthFailureState(this.errorMessage);
}