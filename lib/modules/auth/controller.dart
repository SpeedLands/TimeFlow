import "package:timeflow/data/model/user_model.dart";
import "package:timeflow/data/provider/auth_provider.dart";
import "package:get/get.dart";
import "package:firebase_auth/firebase_auth.dart";

class AuthController extends GetxController {
  final AuthProviderLocal _authProvider = Get.find<AuthProviderLocal>();
  // userData ahora es un reflejo reactivo del estado en AuthProviderLocal.
  // No necesita ser inicializado aquí, ya que se vinculará en onInit.
  final Rx<UserData?> userData = Rx<UserData?>(null);
  var failedAttempts = [false, false, false];

  @override
  void onInit() {
    super.onInit();
    // Enlaza el userData de este controlador al userData del proveedor.
    // Cada vez que el userData del proveedor cambie, el de este controlador
    // también lo hará, manteniendo la UI actualizada.
    userData.bindStream(_authProvider.userData.stream);
  }

  void login(String email, String password) async {
    // El estado de userData se actualizará automáticamente a través del
    // listener en AuthProviderLocal.
    await _authProvider.login(email, password);
  }

  void register(String email, String password, UserData userModel) {
    _authProvider.register(email, password, userModel);
  }

  void logout() {
    // El estado de userData se actualizará a null automáticamente
    // a través del listener en AuthProviderLocal.
    _authProvider.logout();
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
