import 'package:intl/intl.dart';
import 'package:get/get.dart';

// --- Funciones de utilidad para fechas ---

/// Devuelve el número de días en un mes específico.
int daysInMonth(int year, int month) {
  if (month == DateTime.february) {
    final bool isLeap = (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
    return isLeap ? 29 : 28;
  }
  const List<int> daysPerMonth = <int>[0, 31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return daysPerMonth[month];
}

/// Devuelve una lista con los nombres de todos los meses en el idioma local.
List<String> getAllMonthNames({String? locale}) {
  final currentLocale = locale ?? Get.locale?.languageCode ?? 'es';
  List<String> months = [];
  var date = DateTime(2000);

  for (int i = 1; i <= 12; i++) {
    try {
      final monthDate = DateTime(date.year, i);
      months.add(
        DateFormat.MMMM(currentLocale).format(monthDate).capitalizeFirst(),
      );
    } catch (e) {
      // Fallback a español si el idioma no está disponible
      const fallbackMonths = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      months.add(fallbackMonths[i - 1]);
    }
  }
  return months;
}

// --- Extensión para capitalizar ---

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
