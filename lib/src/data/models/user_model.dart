// src/data/models/user_model.dart

class UserModel {
  final String id;
  final String username;
  final String email;
  final bool isAdmin; // 🔹 NOVO CAMPO AQUI

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.isAdmin = false, // 🔹 O padrão é false (usuário comum)
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      isAdmin: map['isAdmin'] ?? false, // 🔹 LÊ O CAMPO AQUI (se não existir, é false)
    );
  }
}