import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:timeflow/data/provider/auth_provider.dart';
import 'package:timeflow/data/services/auth_service.dart';
import 'package:timeflow/data/services/firestore_service.dart';
import 'package:timeflow/modules/agenda/controller.dart';
import 'package:timeflow/modules/auth/controller.dart';
import 'package:timeflow/routes/app_pages.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Asegurar inicialización de widgets
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.lazyPut(() => AgendaController());
  Get.lazyPut(() => AuthController());
  Get.lazyPut(() => AuthService(Get.find()));
  Get.lazyPut(() => FirestoreService());

  initializeDateFormatting('es_ES', null).then((_) => runApp(MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Es importante inicializar los formatos de fecha para 'es_ES'
    // Idealmente en tu `main()` async:
    // void main() async {
    //   WidgetsFlutterBinding.ensureInitialized();
    //   await initializeDateFormatting('es_ES', null); // Asegúrate de importar 'package:intl/date_symbol_data_local.dart';
    //   runApp(MainApp());
    // }
    return GetMaterialApp(
      title: 'TimeFlow Calendario',
      translations: null, // Si tienes traducciones, configúralas aquí
      debugShowCheckedModeBanner: false,
      locale: Locale('es', 'ES'),
      fallbackLocale: const Locale('es', 'ES'), // Idioma por defecto
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        // Define un tema base
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Puedes personalizar más aspectos del tema aquí
      ),
      darkTheme: ThemeData(
        // Tema oscuro opcional
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light, // Usar tema del sistema
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthProviderLocal(Get.find()));
        Get.put(AuthController());
      }),
      // No necesitas Get.put(AgendaController()) aquí si ya lo haces en CalendarScreen
      // o si CalendarScreen usa GetView<AgendaController> que lo manejaría automáticamente.
      // Si necesitas el controlador a nivel de app, puedes ponerlo aquí:
      // initialBinding: BindingsBuilder(() {
      //   Get.put(AgendaController());
      // }),
    );
  }
}
