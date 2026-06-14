import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Busca os dados complementares do Firestore (incluindo o isAdmin)
  Future<UserModel?> _getUserModelFromFirestore(User? user) async {
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserModel(
          id: user.uid,
          username: data['username'] ?? user.displayName ?? 'Usuário',
          email: user.email ?? '',
          isAdmin: data['isAdmin'] ?? false, // 🔹 Carrega o crachá do Firestore!
        );
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário no Firestore: $e');
    }

    // Fallback caso falte o documento no Firestore por algum motivo
    return UserModel(
      id: user.uid,
      username: user.displayName ?? 'Usuário',
      email: user.email ?? '',
      isAdmin: false,
    );
  }

  // Escuta em tempo real se o usuário está logado ou não
  Stream<UserModel?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      return await _getUserModelFromFirestore(user);
    });
  }

  // Registro de novas contas (salva por padrão isAdmin como false)
  Future<UserModel?> register(String username, String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // 1. Atualiza o nome direto no Perfil do Firebase Auth
        await credential.user!.updateDisplayName(username);

        // 2. Salva os dados completos na pasta dele no Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'id': credential.user!.uid,
          'username': username,
          'email': email,
          'isAdmin': false, // 🔹 Todo usuário novo começa como usuário comum
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Recarrega os dados do usuário para garantir a sincronia do Firebase Auth
      await credential.user!.reload();
      final updatedUser = _firebaseAuth.currentUser;

      return await _getUserModelFromFirestore(updatedUser);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Erro ao criar conta.');
    } catch (e) {
      throw Exception('Um erro inesperado aconteceu.');
    }
  }

  // Login com Firebase
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserModelFromFirestore(credential.user);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Erro ao fazer login.');
    } catch (e) {
      throw Exception('Um erro inesperado aconteceu ao tentar entrar.');
    }
  }

  // Logout com Firebase
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}