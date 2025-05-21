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
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _fetchUserData(currentUser.uid);
    }
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
      Get.snackbar(
        "Error",
        "No se pudo obtener los datos del usuario",
        snackPosition: SnackPosition.BOTTOM,
      );
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
        await _authService
            .sendEmailVerification(); // Enviar verificación de email
        Get.snackbar(
          "Registro Exitoso",
          "Se ha enviado un correo de verificación. Por favor, revisa tu bandeja de entrada.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> login(String email, String password) async {
    if (isLocked.value) {
      Get.snackbar(
        "Acceso bloqueado",
        "Has excedido el número de intentos. Intenta más tarde.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      UserData? user = await _authService.login(email, password);
      if (user != null) {
        userData.value = user;
        failedAttempts.value =
            0; // Reiniciar el contador si el login es exitoso
        Get.toNamed("/home");
      }
    } catch (e) {
      failedAttempts.value += 1; // Aumentar el contador de fallos
      Get.snackbar(
        "Error",
        "Credenciales incorrectas (${failedAttempts.value}/$maxAttempts)",
        snackPosition: SnackPosition.BOTTOM,
      );

      if (failedAttempts.value >= maxAttempts) {
        isLocked.value = true; // Bloquear el acceso
        Get.snackbar(
          "Acceso bloqueado",
          "Demasiados intentos fallidos. Intenta más tarde.",
          snackPosition: SnackPosition.BOTTOM,
        );

        // Opcional: desbloqueo automático después de un tiempo
        Future.delayed(Duration(minutes: 5), () {
          failedAttempts.value = 0;
          isLocked.value = false;
        });
      }
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      userData.value = null; // Restablecer los datos del usuario
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      Get.snackbar(
        "Correo Enviado",
        "Se ha enviado un enlace para restablecer tu contraseña.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
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
