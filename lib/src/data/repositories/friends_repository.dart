import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Busca usuários no banco (ignorando o próprio usuário)
  Future<List<Map<String, dynamic>>> searchUsers(String currentUserId, String query) async {
    if (query.isEmpty) return [];

    final snapshot = await _firestore.collection('users').get();
    final lowerQuery = query.toLowerCase();

    // Filtra localmente para permitir buscar por partes do nome
    return snapshot.docs
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .where((user) {
          final username = (user['username'] ?? '').toString().toLowerCase();
          final isNotMe = user['uid'] != currentUserId;
          return isNotMe && username.contains(lowerQuery);
        })
        .toList();
  }

  // 2. Ouve a lista de amigos em tempo real
  Stream<List<Map<String, dynamic>>> getFriendsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'uid': doc.id, ...doc.data()}).toList());
  }

  // 3. Adiciona um amigo
  Future<void> addFriend(String currentUserId, Map<String, dynamic> targetUser) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(targetUser['uid'])
        .set({
      'username': targetUser['username'],
      'email': targetUser['email'],
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // 4. Remove um amigo
  Future<void> removeFriend(String currentUserId, String friendId) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendId)
        .delete();
  }
}