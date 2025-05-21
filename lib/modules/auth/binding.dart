import "package:timeflow/data/provider/auth_provider.dart";
import "package:timeflow/data/services/firestore_service.dart";
import "package:get/get.dart";
import "controller.dart";

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => AuthProviderLocal(Get.find()));
    Get.lazyPut(() => FirestoreService());
  }
}
