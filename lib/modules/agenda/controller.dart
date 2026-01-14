import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeflow/core/utils/date_helpers.dart';
import 'package:timeflow/data/model/agenda_model.dart';
import 'package:timeflow/data/provider/event_provider.dart';

class AgendaController extends GetxController {
  final EventProvider _eventProvider;
  var allFetchedEvents = RxList<Event>([]);

  AgendaController(this._eventProvider);

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
    // Inicializa mesSeleccionadoNombre basado en el focusDay inicial
    updateMesSeleccionadoNombre(focusDay.value);
    selectedDay.value = DateTime.now(); // Seleccionar hoy por defecto
    _listenToEvents(); // Escuchar eventos desde el provider
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
      // Guarda para evitar errores si un evento tiene una fecha de fin anterior a la de inicio.
      if (event.endTime.isBefore(event.startTime)) {
        continue; // Omite este evento y continúa con el siguiente.
      }

      DateTime currentDate = event.startTime;
      // Itera desde el inicio hasta el final del evento.
      while (true) {
        final dayKey = DateTime(currentDate.year, currentDate.month, currentDate.day);

        // Asegura que la lista de eventos para el día exista.
        events.putIfAbsent(dayKey, () => []);

        // Añade el evento solo si no existe ya en la lista para ese día.
        if (!events[dayKey]!.any((e) => e.id == event.id)) {
          events[dayKey]!.add(event);
        }

        // Si el día actual es el mismo que el día de finalización,
        // hemos terminado con este evento, así que salimos del bucle.
        if (isSameDay(currentDate, event.endTime)) {
          break;
        }

        // Pasa al día siguiente.
        currentDate = currentDate.add(const Duration(days: 1));
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
    final nombresMesesLocale = getAllMonthNames(locale: locale);
    mesIndex = nombresMesesLocale.indexWhere((m) => m.toLowerCase() == nombreMes.toLowerCase()) + 1;

    if (mesIndex == 0) {
      return;
    }

    DateTime nuevaFecha = DateTime(focusDay.value.year, mesIndex, 1);
    int diaAUsar = focusDay.value.day;
    if (diaAUsar > daysInMonth(nuevaFecha.year, nuevaFecha.month)) {
      diaAUsar = daysInMonth(nuevaFecha.year, nuevaFecha.month);
    }
    nuevaFecha = DateTime(focusDay.value.year, mesIndex, diaAUsar);

    focusDay.value = nuevaFecha;
    updateMesSeleccionadoNombre(nuevaFecha);
  }

  void updateMesSeleccionadoNombre(DateTime date) {
    mesSeleccionadoNombre.value =
        DateFormat.MMMM(Get.locale?.languageCode ?? 'es').format(date).capitalizeFirst();
  }

  // --- Eventos (si los usas) ---
  List<Event> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return events[normalizedDay] ?? [];
  }

  // void _loadSampleEvents() { ... } // Tu lógica para cargar eventos
  // void addEvent(Event newEvent) { ... } // Tu lógica para añadir eventos

}
