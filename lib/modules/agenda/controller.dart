import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeflow/data/model/agenda_model.dart';
import 'package:timeflow/data/provider/event_provider.dart';

class AgendaController extends GetxController with GetTickerProviderStateMixin {
  // --- Animación para el desplegable de meses en AppBar (si lo usas) ---
  late AnimationController iconRotationController;
  RxBool mostrarMesesDropdown = false.obs;

  final EventProvider _eventProvider = Get.find<EventProvider>();
  var allFetchedEvents = RxList<Event>([]);

  var searchResults = RxList<Event>([]); // Para los resultados de búsqueda
  var isSearching =
      false.obs; // Para saber si la UI de búsqueda está activa (opcional)

  // --- Estado principal del Calendario ---
  var focusDay = DateTime.now().obs;
  var selectedDay = Rx<DateTime?>(null);
  var calendarFormat =
      CalendarFormat.month.obs; // Variable observable para el formato
  var showAgendaView =
      false.obs; // Para cambiar entre TableCalendar y Vista de Agenda

  // --- Estado para tu UI de selección de Mes (usado en AppBar) ---
  var mesSeleccionadoNombre = ''.obs; // Ejemplo: "Enero"

  // --- Eventos (opcional, si tu calendario maneja eventos) ---
  var events = RxMap<DateTime, List<Event>>({});
  var allEventsSorted = RxList<Event>([]);

  @override
  void onInit() {
    super.onInit();
    iconRotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    // Inicializa mesSeleccionadoNombre basado en el focusDay inicial
    updateMesSeleccionadoNombre(focusDay.value);
    selectedDay.value = DateTime.now(); // Seleccionar hoy por defecto
    _listenToEvents(); // Escuchar eventos desde el provider
    // _loadSampleEvents(); // Si tienes eventos de ejemplo
    // print('Controller inicializado. FocusDay: ${focusDay.value}');
  }

  // --- Métodos para la UI ---
  void toggleMesesDropdown() {
    mostrarMesesDropdown.value = !mostrarMesesDropdown.value;
    if (mostrarMesesDropdown.value) {
      iconRotationController.forward();
    } else {
      iconRotationController.reverse();
    }
  }

  void _listenToEvents() {
    _eventProvider.getEvents().listen(
      (eventList) {
        allFetchedEvents.assignAll(eventList);
        _updateCalendarEventsMap(
          eventList,
        ); // Actualiza el RxMap para TableCalendar

        // Si usabas allEventsSorted, puedes actualizarlo aquí:
        // allEventsSorted.assignAll(List<Event>.from(eventList)
        //   ..sort((a, b) => a.startTime.compareTo(b.startTime)));

        update(); // Para refrescar Obx/GetBuilder si es necesario
        // print("Eventos actualizados: ${eventList.length} eventos cargados.");
      },
      onError: (error) {
        // print("Error escuchando eventos: $error");
        Get.snackbar(
          "Error de Eventos",
          "No se pudieron cargar los eventos: $error",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  // Método para realizar la búsqueda
  void searchEvents(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true; // Opcional
    final lowerCaseQuery = query.toLowerCase();

    // Filtra todos los eventos que has cargado
    // Puedes hacer el filtro más sofisticado (ej: buscar en descripción, localización)
    final results =
        allFetchedEvents.where((event) {
          final titleMatch = event.title.toLowerCase().contains(lowerCaseQuery);
          final descriptionMatch =
              event.description?.toLowerCase().contains(lowerCaseQuery) ??
              false;
          // Añade más criterios si quieres:
          // final locationMatch = event.location?.toLowerCase().contains(lowerCaseQuery) ?? false;
          return titleMatch || descriptionMatch /* || locationMatch */;
        }).toList();

    // Opcional: Ordenar los resultados (ej. por fecha de inicio)
    results.sort((a, b) => a.startTime.compareTo(b.startTime));

    searchResults.assignAll(results);
    // print("Búsqueda por '$query': ${results.length} resultados encontrados.");
  }

  void clearSearch() {
    searchResults.clear();
    isSearching.value = false; // Opcional
  }

  // Método para navegar a un evento desde la búsqueda
  void goToEventDate(Event event) {
    focusDay.value = event.startTime;
    selectedDay.value = event.startTime; // También selecciona el día del evento
    // Opcional: Si quieres cambiar el formato del calendario al ver un evento
    // if (calendarFormat.value != CalendarFormat.month) {
    //   calendarFormat.value = CalendarFormat.month;
    // }
    // print(
    //   "Navegando a la fecha del evento: ${event.title} - ${event.startTime}",
    // );
  }

  void _updateCalendarEventsMap(List<Event> eventList) {
    events.clear();
    for (var event in eventList) {
      DateTime currentDate = event.startTime;
      // Itera desde el inicio hasta el final del evento (inclusive)
      while (!currentDate.isAfter(event.endTime)) {
        final dayKey = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
        if (events[dayKey] == null) {
          events[dayKey] = [];
        }
        // Evita añadir duplicados al mismo día si el stream emite múltiples veces con los mismos datos
        // (Mejor usar el ID del evento si ya lo tienes en el modelo)
        if (!events[dayKey]!.any((e) => e.id == event.id)) {
          events[dayKey]!.add(event);
        }
        currentDate = currentDate.add(const Duration(days: 1));
        // Si el evento es de día completo y endTime es 00:00 del día siguiente,
        // y no quieres que aparezca en ese día siguiente, ajusta la condición del while.
        // Por ejemplo: while (currentDate.isBefore(event.endTime) || isSameDay(currentDate, event.endTime))
        // y si endTime es 00:00 del día siguiente, podrías hacer event.endTime.subtract(Duration(seconds:1))
        // para la comparación.
        // La forma más simple es que si un evento termina a las 00:00, considerarlo hasta el día anterior.
        // La lógica actual incluye el día de endTime si la hora no es 00:00:00.
        // Si endTime es, por ejemplo, 23:59:59 del mismo día, solo se agregará una vez.
        // Si endTime es el día siguiente a las 10:00, se agregará al día de inicio y al de fin.

        // Pequeña salvaguarda para evitar bucles infinitos si startTime y endTime son idénticos
        // y el evento no avanza. Si el evento dura menos de un día, solo se procesa una vez.
        if (isSameDay(event.startTime, event.endTime) &&
            event.startTime.isAtSameMomentAs(event.endTime)) {
          break;
        }
      }
    }
  }

  Future<void> addNewEvent(Event newEvent) async {
    try {
      await _eventProvider.addEvent(newEvent);
      Get.snackbar(
        "Éxito",
        "Evento '${newEvent.title}' agregado.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // print("Error agregando evento: $e");
      Get.snackbar(
        "Error",
        "No se pudo agregar el evento: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateExistingEvent(Event updatedEvent) async {
    if (updatedEvent.id == null) {
      Get.snackbar(
        "Error",
        "ID de evento no encontrado para actualizar.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    try {
      await _eventProvider.updateEvent(updatedEvent, updatedEvent.id!);
      Get.snackbar(
        "Éxito",
        "Evento '${updatedEvent.title}' actualizado.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // print("Error actualizando evento: $e");
      Get.snackbar(
        "Error",
        "No se pudo actualizar el evento: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeEvent(String eventId, String eventTitle) async {
    try {
      // Opcional: Mostrar un diálogo de confirmación antes de eliminar
      // bool confirmDelete = await Get.dialog(...);
      // if (!confirmDelete) return;

      await _eventProvider.deleteEvent(eventId);
      Get.snackbar(
        "Éxito",
        "Evento '$eventTitle' eliminado.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // print("Error eliminando evento: $e");
      Get.snackbar(
        "Error",
        "No se pudo eliminar el evento: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void toggleCalendarView() {
    showAgendaView.value = !showAgendaView.value;
    // print("Vista de agenda: ${showAgendaView.value}");
  }

  // --- Métodos para TableCalendar ---
  void onDaySelected(DateTime day, DateTime focusedDay) {
    if (!isSameDay(selectedDay.value, day)) {
      selectedDay.value = day;
      focusDay.value = focusedDay;
      updateMesSeleccionadoNombre(focusedDay);
      // print("Día seleccionado: $day, Día enfocado: $focusedDay");
    }
  }

  void onPageChanged(DateTime focusedDay) {
    focusDay.value = focusedDay;
    updateMesSeleccionadoNombre(focusedDay);
    // print("Página cambiada, nuevo FocusDay: $focusedDay");
  }

  void changeCalendarFormat(CalendarFormat newFormat) {
    if (calendarFormat.value != newFormat) {
      calendarFormat.value = newFormat;
      // print("Formato de calendario cambiado a: $newFormat");
    }
  }

  // --- Métodos para tu selector de mes personalizado (usado en AppBar y MesesToggleWidget) ---
  void seleccionarMesDesdeDropdown(String nombreMes) {
    final locale = Get.locale?.languageCode ?? 'es';
    int mesIndex = 1;
    final nombresMesesLocale = obtenerTodosLosNombresDeMeses(locale);
    mesIndex =
        nombresMesesLocale.indexWhere(
          (m) => m.toLowerCase() == nombreMes.toLowerCase(),
        ) +
        1;

    if (mesIndex == 0) {
      // print("Error: Mes '$nombreMes' no reconocido para locale '$locale'.");
      return;
    }

    DateTime nuevaFecha = DateTime(focusDay.value.year, mesIndex, 1);
    int diaAUsar = focusDay.value.day;
    if (diaAUsar > _diasEnMes(nuevaFecha.year, nuevaFecha.month)) {
      diaAUsar = _diasEnMes(nuevaFecha.year, nuevaFecha.month);
    }
    nuevaFecha = DateTime(focusDay.value.year, mesIndex, diaAUsar);

    focusDay.value = nuevaFecha;
    updateMesSeleccionadoNombre(nuevaFecha);

    if (mostrarMesesDropdown.value) {
      toggleMesesDropdown();
    }
    // print(
    //   'Mes seleccionado desde dropdown: $nombreMes, Nueva fecha enfocada: $nuevaFecha',
    // );
  }

  void updateMesSeleccionadoNombre(DateTime date) {
    mesSeleccionadoNombre.value =
        StringExtension(
          DateFormat.MMMM(Get.locale?.languageCode ?? 'es').format(date),
        ).capitalizeFirst();
  }

  // Helper para obtener el número de días en un mes
  int _diasEnMes(int year, int month) {
    if (month == DateTime.february) {
      final bool esBisiesto =
          (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
      return esBisiesto ? 29 : 28;
    }
    const List<int> diasPorMes = <int>[
      0,
      31,
      -1,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];
    return diasPorMes[month];
  }

  // --- Helpers ---
  List<String> obtenerTodosLosNombresDeMeses(String locale) {
    List<String> meses = [];
    var typicalYearDate = DateTime(2000);
    for (int i = 1; i <= 12; i++) {
      try {
        final monthDate = DateTime(typicalYearDate.year, i);
        meses.add(
          StringExtension(
            DateFormat.MMMM(locale).format(monthDate),
          ).capitalizeFirst(),
        );
      } catch (e) {
        // print(
        //   "Error formateando mes $i para locale $locale: $e. Usando fallback.",
        // );
        const nombresMesesEs = [
          'Enero',
          'Febrero',
          'Marzo',
          'Abril',
          'Mayo',
          'Junio',
          'Julio',
          'Agosto',
          'Septiembre',
          'Octubre',
          'Noviembre',
          'Diciembre',
        ];
        meses.add(nombresMesesEs[i - 1]);
      }
    }
    return meses;
  }

  // --- Eventos (si los usas) ---
  List<Event> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return events[normalizedDay] ?? [];
  }

  // void _loadSampleEvents() { ... } // Tu lógica para cargar eventos
  // void addEvent(Event newEvent) { ... } // Tu lógica para añadir eventos

  @override
  void onClose() {
    iconRotationController.dispose();
    super.onClose();
  }
}

// Extensión para capitalizar
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
