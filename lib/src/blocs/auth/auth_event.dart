// src/blocs/auth/auth_event.dart
import '../../data/models/user_model.dart'; // Adicione este import se necessário

abstract class AuthEvent {}

class AuthStatusChangedEvent extends AuthEvent {
  final UserModel? user; // CORREÇÃO: Trocado Object? por UserModel?
  AuthStatusChangedEvent(this.user);
}

class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  LoginRequestedEvent(this.email, this.password);
}

class RegisterRequestedEvent extends AuthEvent {
  final String username; // <-- LINHA NOVA
  final String email;
  final String password;

  RegisterRequestedEvent({

    required this.username, // <-- LINHA NOVA
    required this.email,
    required this.password,
  });
}

class LogoutRequestedEvent extends AuthEvent {}