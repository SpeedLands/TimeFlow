import "package:cloud_firestore/cloud_firestore.dart";

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Agregar documento a cualquier colección
  Future<String?> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> setDocument(
    String documentId,
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      return;
    }
  }

  // Obtener documento por ID de cualquier colección
  Future<DocumentSnapshot?> getDocument(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      return null;
    }
  }

  // Actualizar documento en cualquier colección
  Future<bool> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Eliminar documento en cualquier colección
  Future<bool> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Escuchar cambios en cualquier colección
  Stream<QuerySnapshot> listenToCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }
}
