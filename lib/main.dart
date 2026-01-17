import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:timeflow/data/provider/auth_provider.dart';
import 'package:timeflow/data/provider/event_provider.dart';
import 'package:timeflow/data/services/auth_service.dart';
import 'package:timeflow/data/services/firestore_service.dart';
import 'package:timeflow/modules/agenda/controller.dart';
import 'package:timeflow/global/app_theme.dart';
import 'package:timeflow/modules/auth/controller.dart';
import 'package:timeflow/routes/app_pages.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Asegurar inicialización de widgets
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Inicializa los servicios principales
  Get.lazyPut(() => FirestoreService());

  // 2. Inicializa los proveedores que dependen de los servicios
  Get.lazyPut(() => AuthProviderLocal(Get.find<FirestoreService>()));

  // 3. Inicializa los servicios que dependen de los proveedores
  Get.lazyPut(() => AuthService(Get.find<AuthProviderLocal>()));
  Get.lazyPut(() => EventProvider(Get.find<FirestoreService>()));


  // 4. Inicializa los controladores
  Get.lazyPut(() => AgendaController(Get.find<EventProvider>()));
  Get.lazyPut(() => AuthController());


  initializeDateFormatting('es_ES', null).then((_) => runApp(const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TimeFlow Calendario',
      translations: null,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Usa el tema del sistema (claro u oscuro)
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      // initialBinding ya no es necesario si todo se inicializa en main()
      // No necesitas Get.put(AgendaController()) aquí si ya lo haces en CalendarScreen
      // o si CalendarScreen usa GetView<AgendaController> que lo manejaría automáticamente.
      // Si necesitas el controlador a nivel de app, puedes ponerlo aquí:
      // initialBinding: BindingsBuilder(() {
      //   Get.put(AgendaController());
      // }),
    );
  }
}
