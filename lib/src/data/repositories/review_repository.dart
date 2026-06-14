import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_hub/src/blocs/review/review.dart';


class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para salvar a resenha
  Future<void> createReview(Review review) async {
    try {
      await _firestore
          .collection('reviews')
          .doc(review.id)
          .set(review.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar resenha: $e');
    }
  }

  // 🔹 FUNÇÃO NOVA: Ouve as resenhas em TEMPO REAL (Stream)
  Stream<List<Review>> getUserReviewsStream(String userId) {
    return _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId) 
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList());
  }

  // Função antiga (mantida caso você precise buscar apenas 1 vez em outro lugar)
  Future<List<Review>> getUserReviews(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Erro ao buscar resenhas: $e');
    }
  }

  // 🔹 NOVA Função: Deleta a resenha
  Future<void> deleteReview(String reviewId) async {
    await FirebaseFirestore.instance.collection('reviews').doc(reviewId).delete();
  }

}