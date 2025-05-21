import "package:timeflow/data/model/user_model.dart";
import "package:timeflow/data/services/firestore_service.dart";
import "package:firebase_auth/firebase_auth.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService;
  final String collection = "users";

  AuthService(this._firestoreService);

  Future<UserData?> register(
    String email,
    String password,
    UserData userData,
  ) async {
    try {
      // Crear el usuario con Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guarda el usuario en Firestore
      await _firestoreService.setDocument(
        userCredential.user!.uid,
        collection,
        userData.toMap(),
      );

      return UserData(uid: userCredential.user!.uid, email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserData?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar si userCredential.user es nulo
      final user = userCredential.user;
      if (user == null) return null;

      // Obtén los datos del usuario desde Firestore
      final doc = await _firestoreService.getDocument(collection, user.uid);

      // Si el documento no existe o no tiene datos, devuelve null
      final data = doc?.data();
      if (data == null) return null;

      var userData = UserData.fromFirestore(data as Map<String, dynamic>);

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserData?> getUserData(String id) async {
    try {
      final doc = await _firestoreService.getDocument(collection, id);

      // Si el documento no existe o no tiene datos, devuelve null
      final data = doc?.data();
      if (data == null) return null;

      return UserData.fromFirestore(data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }
}
