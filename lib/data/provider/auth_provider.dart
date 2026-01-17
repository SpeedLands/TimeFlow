import "package:timeflow/data/services/auth_service.dart";
import "package:get/get.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:timeflow/data/model/user_model.dart";

class AuthProviderLocal extends GetxController {
  final AuthService _authService;
  final Rx<UserData?> userData = Rx<UserData?>(null);
  final RxInt failedAttempts = 0.obs; // Contador de intentos fallidos
  final RxBool isLocked = false.obs; // Estado de bloqueo
  final int maxAttempts = 3; // Número máximo de intentos

  AuthProviderLocal(this._authService);

  @override
  void onReady() {
    super.onReady();
    // El listener de authStateChanges se convierte en la única fuente de verdad
    // para el estado de autenticación del usuario.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        userData.value = null;
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      var doc = await _authService.getUserData(uid);
      if (doc != null) {
        userData.value = doc;
      } else {
        // Si el usuario no tiene datos en Firestore, asigna un rol 'client' por defecto
        userData.value = UserData(uid: uid, email: "");
      }
    } catch (e) {
      // Lanza una excepción para que la UI pueda manejarla si es necesario
      throw Exception("No se pudo obtener los datos del usuario");
    }
  }

  Future<void> register(
    String email,
    String password,
    UserData userDataModel,
  ) async {
    try {
      UserData? user = await _authService.register(
        email,
        password,
        userDataModel,
      );
      if (user != null) {
        userData.value = user;
        await _authService.sendEmailVerification();
      }
    } catch (e) {
      // Lanza la excepción para que la UI pueda manejarla
      throw Exception(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    if (isLocked.value) {
      throw Exception("Acceso bloqueado. Has excedido el número de intentos.");
    }

    try {
      UserData? user = await _authService.login(email, password);
      if (user != null) {
        userData.value = user;
        failedAttempts.value = 0; // Reiniciar el contador en éxito
      }
    } catch (e) {
      failedAttempts.value += 1;
      if (failedAttempts.value >= maxAttempts) {
        isLocked.value = true;
        // Opcional: Desbloqueo automático después de un tiempo
        Future.delayed(const Duration(minutes: 5), () {
          failedAttempts.value = 0;
          isLocked.value = false;
        });
        throw Exception("Acceso bloqueado. Demasiados intentos fallidos.");
      }
      // Lanza una excepción más informativa para la UI
      throw Exception("Credenciales incorrectas (${failedAttempts.value}/$maxAttempts)");
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      userData.value = null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> loadUserData() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _fetchUserData(currentUser.uid);
    }
  }

  Future<void> sendEmailVerification() async {
    _authService.sendEmailVerification();
  }

  Future<bool> isVerifyEmail() async {
    return _authService.isEmailVerified();
  }
}
