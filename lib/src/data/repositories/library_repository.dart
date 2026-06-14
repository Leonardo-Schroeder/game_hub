import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart'; 

class LibraryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Salva o jogo na subcoleção 'library' do usuário
  Future<void> addGame(String userId, Game game, String status) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('library')
        .doc(game.id) // Usar o ID do jogo como documento impede que ele seja salvo duplicado!
        .set({
      'id': game.id,
      'title': game.title,
      'imageUrl': game.imageUrl,
      'status': status, // 'zerado' ou 'wishlist'
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

 Stream<List<Map<String, dynamic>>> getGamesStream(String userId, String status) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('library')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'docId': doc.id, // Precisamos desse ID para conseguir deletar depois!
                'imageUrl': (data['imageUrl'] != null) ? data['imageUrl'].toString().trim() : '',
              };
            }).toList());
  }

  // 🔹 NOVA Função: Remove o jogo da lista do usuário
  Future<void> removeGame(String userId, String docId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('library')
        .doc(docId)
        .delete();
  }
  
}