import "package:timeflow/data/model/user_model.dart";
import "package:timeflow/data/provider/auth_provider.dart";
import "package:get/get.dart";
import "package:firebase_auth/firebase_auth.dart";

class AuthController extends GetxController {
  final AuthProviderLocal _authProvider = Get.find();
  final Rx<UserData?> userData = Rx<UserData?>(
    null,
  ); // Estado reactivo del usuario
  var failedAttempts = [false, false, false];

  @override
  void onReady() {
    super.onReady();
    _checkAuthState(); // Verifica el estado de autenticación cuando el controlador esté listo
  }

  /// ✅ Verifica el estado de autenticación
  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _authProvider
            .loadUserData(); // Obtiene los datos del usuario desde Firestore
        userData.value = _authProvider.userData.value; // Actualiza userData

        // print("Usuario autenticado: ${userData.value?.email}");
      } else {
        userData.value = null; // Si el usuario cierra sesión, resetea los datos
        // print("Cerró sesión");
      }
    });
  }

  void login(String email, String password) async {
    await _authProvider.login(email, password);
    userData.value =
        _authProvider.userData.value; // Asegurar que userData se actualiza
  }

  void register(String email, String password, UserData userModel) {
    _authProvider.register(email, password, userModel);
  }

  void logout() {
    _authProvider.logout();
    userData.value = null; // Resetear userData al cerrar sesión
  }

  void resetPassword(String email) {
    _authProvider.resetPassword(email);
  }

  void sendEmailVerification() {
    _authProvider.sendEmailVerification();
  }

  /// ✅ Devuelve `true` si el usuario está autenticado
  bool get isAuthenticated =>
      userData.value != null && userData.value!.uid.isNotEmpty;
}
