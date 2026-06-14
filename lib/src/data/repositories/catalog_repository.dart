// Local: src/data/repositories/catalog_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart'; // Ajuste o caminho do seu model se necessário

class CatalogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Escuta todos os jogos cadastrados no sistema
  Stream<List<Game>> getCatalogStream() {
    return _firestore.collection('games').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Game(
          id: doc.id,
          title: data['title'] ?? 'Sem Título',
          imageUrl: data['imageUrl'] ?? '',
          genre: data['genre'] ?? 'Geral',
          rating: (data['rating'] ?? 0.0).toDouble(),
        );
      }).toList();
    });
  }
}