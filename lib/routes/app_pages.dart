import 'package:get/get.dart';
import 'package:timeflow/modules/agenda/agenda.dart';
import 'package:timeflow/modules/agenda/binding.dart';
import 'package:timeflow/modules/auth/binding.dart';
import 'package:timeflow/modules/auth/login_page.dart';
import 'package:timeflow/modules/auth/register_page.dart';
import 'package:timeflow/modules/settings/settings.dart';
import 'package:timeflow/routes/app_routes.dart';

class AppPages {
  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => CalendarScreen(),
      transition: Transition.fadeIn,
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.register,
      page: () => SignupPage(),
      binding: AuthBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: Routes.settings,
      page: () => ConfiguracionScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
