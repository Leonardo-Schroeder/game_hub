import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Escuta TODAS as resenhas de TODOS os usuários do app em tempo real
  Stream<QuerySnapshot> getAllReviewsStream() {
    return _firestore.collectionGroup('reviews').snapshots();
  }

  // 2. Deleta uma resenha específica de um usuário
  Future<void> deleteReview(String userId, String reviewId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }

  // 3. Cadastra um novo jogo na coleção global do sistema
  Future<void> addNewGame(String title, String imageUrl, String genre, double rating) async {
    final gameDoc = _firestore.collection('games').doc();
    
    await gameDoc.set({
      'id': gameDoc.id,
      'title': title,
      'imageUrl': imageUrl,
      'genre': genre,
      'rating': rating, // Adicionamos a nota!
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}