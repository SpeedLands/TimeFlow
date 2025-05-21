import "package:timeflow/data/provider/auth_provider.dart";
import "package:timeflow/data/provider/event_provider.dart";
import "package:timeflow/data/services/firestore_service.dart";
import "package:get/get.dart";
import "package:timeflow/modules/auth/controller.dart";
import "controller.dart";

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => AuthProviderLocal(Get.find()));
    Get.lazyPut(() => FirestoreService());
    Get.lazyPut(() => AgendaController());
    Get.lazyPut(() => EventProvider(Get.find()));
  }
}
