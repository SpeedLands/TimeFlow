import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeflow/data/model/agenda_model.dart';
import 'package:timeflow/global/custom_appbar.dart';
import 'package:timeflow/global/custom_mes.dart';
import 'package:timeflow/global/custom_sidebar.dart';
import 'package:timeflow/global/custom_text.dart';
import 'package:timeflow/modules/agenda/controller.dart';

class CalendarScreen extends StatelessWidget {
  CalendarScreen({super.key});

  // Usar el AgendaController real con la lógica de eventos
  final AgendaController controller = Get.find<AgendaController>();

  @override
  Widget build(BuildContext context) {
    // Asegúrate de que Intl esté inicializado para el locale 'es' o 'es_ES'
    // Esto usualmente se hace en main()
    // initializeDateFormatting('es_ES', null); // Ejemplo

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: Drawer(child: CustomSidebar()),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTabletOrDesktop = constraints.maxWidth > 700;
          Widget calendarContent = _buildCalendarContent(
            context,
            isTabletOrDesktop,
          );

          if (isTabletOrDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: calendarContent,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildEventsPanelForSelectedDay(
                    context,
                  ), // Panel de eventos separado
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  calendarContent,
                  _buildEventsListForSelectedDayMobile(
                    context,
                  ), // Lista de eventos para móvil
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context, controller);
        },
        tooltip: "Agregar Evento",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarContent(BuildContext context, bool isWideScreen) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MesesToggleGetXWidget(), // Este widget debe interactuar con controller.focusDay
        const SizedBox(height: 16.0),
        Obx(() {
          // Obx para reaccionar a cambios en focusDay, selectedDay, events
          return Card(
            elevation: isWideScreen ? 4.0 : 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar<Event>(
                // Especificar el tipo de evento
                locale: Get.locale?.languageCode ?? 'es',
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: true,
                  titleTextStyle:
                      theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ) ??
                      const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                  formatButtonTextStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                  formatButtonDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  // Si MesesToggleGetXWidget maneja el título, puedes omitir titleTextFormatter
                  // o asegurarte que ambos estén sincronizados.
                  // La sincronización actual es que MesesToggleGetXWidget actualiza controller.focusDay
                  // y TableCalendar lee controller.focusDay.
                  // El título de TableCalendar (si se muestra) usará su propio formateador.
                  titleTextFormatter: (date, locale) {
                    // Usa el método del controlador para mantener la consistencia si lo tienes
                    // o formatea directamente aquí.
                    // controller.updateMesSeleccionadoNombre(date); // Esto actualiza una variable del controller
                    // return controller.mesSeleccionadoNombre.value; // si quieres que sea reactivo al controller
                    // O formateo directo:
                    final text = DateFormat.yMMMM(locale).format(date);
                    return text[0].toUpperCase() + text.substring(1);
                  },
                ),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mes',
                  CalendarFormat.twoWeeks: '2 Semanas',
                  CalendarFormat.week: 'Semana',
                },
                // --- CARGA DE EVENTOS ---
                eventLoader: (day) {
                  // Usa el método getEventsForDay de tu AgendaController
                  return controller.getEventsForDay(day);
                },
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    final text = DateFormat.E(
                      Get.locale?.languageCode ?? 'es',
                    ).format(day); // E para nombre corto (Lun, Mar)
                    return Center(
                      child: CustomText(
                        text:
                            text[0].toUpperCase() +
                            (text.length > 1
                                ? text.substring(1, min(text.length, 3))
                                : ""), // Ej: Lun, Mar
                        type: CustomTextType.subtitulo,
                        // style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(
                          4.0,
                        ), // Margen para el círculo
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    );
                  },
                  // --- MARCADORES DE EVENTOS ---
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventsMarker(day, events, theme),
                      );
                    }
                    return null;
                  },
                ),
                calendarFormat: controller.calendarFormat.value,
                onFormatChanged: (format) {
                  controller.changeCalendarFormat(
                    format,
                  ); // Usa el método del controller
                },
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: controller.focusDay.value,
                onPageChanged: (focusedDay) {
                  controller.onPageChanged(
                    focusedDay,
                  ); // Usa el método del controller
                },
                selectedDayPredicate: (day) {
                  return isSameDay(controller.selectedDay.value, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  controller.onDaySelected(
                    selectedDay,
                    focusedDay,
                  ); // Usa el método del controller
                  if (!isWideScreen) {
                    // En móvil, al seleccionar un día, podríamos querer hacer scroll hacia la lista de eventos
                    // o simplemente dejar que la lista debajo se actualice.
                  }
                },
                calendarStyle: CalendarStyle(
                  weekendTextStyle: TextStyle(color: Colors.red.shade700),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- WIDGET PARA MARCADORES DE EVENTOS ---
  Widget _buildEventsMarker(DateTime day, List<Event> events, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            events.length > 1
                ? Colors.orange
                : theme
                    .colorScheme
                    .secondary, // Color diferente si hay múltiples eventos
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- PANEL DE EVENTOS PARA TABLET/DESKTOP ---
  Widget _buildEventsPanelForSelectedDay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Obx(() {
        if (controller.selectedDay.value == null) {
          return Center(
            child: CustomText(
              text: "Selecciona un día para ver los eventos",
              type: CustomTextType.subtitulo,
            ),
          );
        }
        final selectedEvents = controller.getEventsForDay(
          controller.selectedDay.value!,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text:
                  "Eventos para ${DateFormat.yMMMMEEEEd('es').format(controller.selectedDay.value!)}",
              type: CustomTextType.titulo,
            ),
            const SizedBox(height: 16.0),
            if (selectedEvents.isEmpty)
              CustomText(
                text: "No hay eventos para este día.",
                type: CustomTextType.parrafo,
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = selectedEvents[index];
                    final screenWidth = Get.width;
                    bool useColumnForActions =
                        screenWidth > 700 && screenWidth <= 950;
                    Widget trailingActions;

                    if (useColumnForActions) {
                      trailingActions = Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center, // Centra los iconos verticalmente
                        mainAxisSize:
                            MainAxisSize
                                .min, // Para que la columna no ocupe más de lo necesario
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                            ), // Iconos un poco más pequeños
                            padding:
                                EdgeInsets
                                    .zero, // Reduce el padding si es necesario
                            constraints:
                                BoxConstraints(), // Quita restricciones de tamaño por defecto si es necesario
                            tooltip: "Editar",
                            onPressed: () {
                              _showEditEventDialog(context, event, controller);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            tooltip: "Eliminar",
                            onPressed: () {
                              _confirmDeleteEvent(context, event, controller);
                            },
                          ),
                        ],
                      );
                    } else {
                      // Layout de fila por defecto (para pantallas muy anchas o muy estrechas donde el ListTile se adapta bien)
                      trailingActions = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            tooltip: "Editar",
                            onPressed: () {
                              _showEditEventDialog(context, event, controller);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            tooltip: "Eliminar",
                            onPressed: () {
                              _confirmDeleteEvent(context, event, controller);
                            },
                          ),
                        ],
                      );
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: event.color,
                          child: Text(
                            event.title[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: CustomText(
                          text: event.title,
                          type: CustomTextType.subtitulo,
                          maxLines: 2,
                        ),
                        subtitle: CustomText(
                          text:
                              "${DateFormat.Hm('es').format(event.startTime)} - ${DateFormat.Hm('es').format(event.endTime)}\n${event.description ?? ''}",
                          type: CustomTextType.parrafo,
                          maxLines: 3,
                        ),
                        trailing: trailingActions,
                        onTap: () {
                          // print("Ver detalles evento: ${event.title}");
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }

  // --- LISTA DE EVENTOS PARA MÓVIL ---
  Widget _buildEventsListForSelectedDayMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Obx(() {
        if (controller.selectedDay.value == null) {
          return const SizedBox.shrink(); // No mostrar nada si no hay día seleccionado
        }
        final selectedEvents = controller.getEventsForDay(
          controller.selectedDay.value!,
        );
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest, // Un color de fondo sutil
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text:
                    "Eventos para ${DateFormat.yMMMMEEEEd('es').format(controller.selectedDay.value!)}",
                type: CustomTextType.titulo,
              ),
              const SizedBox(height: 8),
              if (selectedEvents.isEmpty)
                CustomText(
                  text: "No hay eventos para este día.",
                  type: CustomTextType.parrafo,
                )
              else
                ListView.builder(
                  shrinkWrap: true, // Importante dentro de una Column
                  physics:
                      const NeverScrollableScrollPhysics(), // Si la Column ya es Scrollable
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = selectedEvents[index];
                    return Card(
                      // Usar Card para cada evento también en móvil
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: event.color,
                          child: Text(
                            event.title[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: CustomText(
                          text: event.title,
                          type: CustomTextType.subtitulo,
                        ),
                        subtitle: CustomText(
                          text:
                              "${DateFormat.Hm('es').format(event.startTime)} - ${DateFormat.Hm('es').format(event.endTime)}\n${event.description ?? ''}",
                          type: CustomTextType.parrafo,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 20),
                              onPressed:
                                  () => _showEditEventDialog(
                                    context,
                                    event,
                                    controller,
                                  ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed:
                                  () => _confirmDeleteEvent(
                                    context,
                                    event,
                                    controller,
                                  ),
                            ),
                          ],
                        ),
                        onTap: () {
                          /* Ver detalles */
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  // --- DIÁLOGOS CRUD (EJEMPLOS BÁSICOS) ---
  void _showAddEventDialog(BuildContext context, AgendaController controller) {
    // Pasamos el controller
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    // Estado inicial para los selectores
    DateTime selectedDate = controller.selectedDay.value ?? DateTime.now();
    TimeOfDay startTime = TimeOfDay.fromDateTime(
      selectedDate.copyWith(hour: DateTime.now().hour, minute: 0),
    ); // Hora actual redondeada
    TimeOfDay endTime = TimeOfDay.fromDateTime(
      selectedDate.copyWith(hour: DateTime.now().hour + 1, minute: 0),
    ); // Una hora después
    Color eventColor = Colors.blue; // Color por defecto

    // Lista de colores predefinidos (alternativa simple a flutter_colorpicker)
    final List<Color> predefinedColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    Get.defaultDialog(
      title: "Agregar Evento",
      titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      contentPadding: EdgeInsets.all(20),
      content: StatefulBuilder(
        // Para manejar el estado interno del diálogo
        builder: (BuildContext context, StateSetter setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Título",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Descripción (opcional)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20),

                // // --- Selector de Fecha ---
                // CustomText(text: "Fecha:", type: CustomTextType.subtitulo),
                SizedBox(height: 5),
                InkWell(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      locale: Get.locale, // Usa el locale de GetX
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setStateDialog(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat.yMMMMEEEEd(
                            Get.locale?.languageCode ?? 'es',
                          ).format(selectedDate),
                        ),
                        Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // --- Selectores de Hora ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //           CustomText(
                          //             text: "Inicio:",
                          //             type: CustomTextType.subtitulo,
                          //           ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: startTime,
                                  );
                              if (pickedTime != null &&
                                  pickedTime != startTime) {
                                setStateDialog(() {
                                  startTime = pickedTime;
                                  // Opcional: Ajustar endTime si startTime es posterior a endTime
                                  final startDateTime = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    startTime.hour,
                                    startTime.minute,
                                  );
                                  final endDateTime = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    endTime.hour,
                                    endTime.minute,
                                  );
                                  if (startDateTime.isAfter(endDateTime) ||
                                      startDateTime.isAtSameMomentAs(
                                        endDateTime,
                                      )) {
                                    endTime = TimeOfDay.fromDateTime(
                                      startDateTime.add(Duration(hours: 1)),
                                    );
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(startTime.format(context)),
                                  Icon(Icons.access_time, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //           CustomText(
                          //             text: "Fin:",
                          //             type: CustomTextType.subtitulo,
                          //           ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: endTime,
                                  );
                              if (pickedTime != null && pickedTime != endTime) {
                                final startDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  startTime.hour,
                                  startTime.minute,
                                );
                                final proposedEndDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );

                                if (proposedEndDateTime.isAfter(
                                  startDateTime,
                                )) {
                                  setStateDialog(() {
                                    endTime = pickedTime;
                                  });
                                } else {
                                  Get.snackbar(
                                    "Hora Inválida",
                                    "La hora de fin debe ser posterior a la hora de inicio.",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(endTime.format(context)),
                                  Icon(Icons.access_time_filled, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // // --- Selector de Color ---
                // CustomText(text: "Color:", type: CustomTextType.subtitulo),
                SizedBox(height: 10),
                // Opción 1: Lista predefinida de colores
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      predefinedColors.map((color) {
                        return InkWell(
                          onTap: () {
                            setStateDialog(() {
                              eventColor = color;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    eventColor == color
                                        ? Theme.of(context).primaryColorDark
                                        : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),

                // Opción 2: Usar flutter_colorpicker (descomenta y ajusta si lo prefieres)
                /*
              SizedBox(height: 10),
              ElevatedButton(
                child: Text("Seleccionar Color"),
                style: ElevatedButton.styleFrom(backgroundColor: eventColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      Color pickerColor = eventColor;
                      return AlertDialog(
                        title: const Text('Elige un color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (color) => pickerColor = color,
                            // showLabel: true, // Muestra etiquetas HSL, RGB, etc.
                            // pickerAreaHeightPercent: 0.8,
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('OK'),
                            onPressed: () {
                              setStateDialog(() {
                                eventColor = pickerColor;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              */
              ],
            ),
          );
        },
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        ),
        child: Text("Guardar", style: TextStyle(fontSize: 16)),
        onPressed: () {
          if (titleController.text.isNotEmpty) {
            final finalStartTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              startTime.hour,
              startTime.minute,
            );
            final finalEndTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              endTime.hour,
              endTime.minute,
            );

            if (finalEndTime.isBefore(finalStartTime) ||
                finalEndTime.isAtSameMomentAs(finalStartTime)) {
              Get.snackbar(
                "Error de Horas",
                "La hora de fin debe ser posterior a la hora de inicio.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }

            final newEvent = Event(
              // id: null, // Firestore genera el ID al agregar
              title: titleController.text,
              description:
                  descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
              startTime: finalStartTime,
              endTime: finalEndTime,
              color: eventColor, // Usar el color seleccionado
            );
            // print(
            //   "Intentando agregar evento: ${newEvent.toMap()}",
            // ); // Para depurar
            controller.addNewEvent(newEvent);
            Get.back(); // Cerrar diálogo
          } else {
            Get.snackbar(
              "Error",
              "El título no puede estar vacío.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
      cancel: TextButton(child: Text("Cancelar"), onPressed: () => Get.back()),
    );
  }

  void _showEditEventDialog(
    BuildContext context,
    Event eventToEdit,
    AgendaController controller,
  ) {
    // Pasamos el evento y el controller
    // Inicializar controladores de texto con los valores del evento
    final titleController = TextEditingController(text: eventToEdit.title);
    final descriptionController = TextEditingController(
      text: eventToEdit.description,
    );

    // Estado inicial para los selectores, cargado desde eventToEdit
    DateTime selectedDate = DateTime(
      eventToEdit.startTime.year,
      eventToEdit.startTime.month,
      eventToEdit.startTime.day,
    );
    TimeOfDay startTime = TimeOfDay.fromDateTime(eventToEdit.startTime);
    TimeOfDay endTime = TimeOfDay.fromDateTime(eventToEdit.endTime);
    Color eventColor = eventToEdit.color; // Usar el color del evento existente

    final List<Color> predefinedColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    Get.defaultDialog(
      title: "Editar Evento",
      titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      contentPadding: EdgeInsets.all(20),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Título",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Descripción (opcional)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20),

                // --- Selector de Fecha ---
                // CustomText(
                //   text: "Fecha:",
                //   type: CustomTextType.subtitulo,
                // ), // Asumiendo que tienes CustomText
                SizedBox(height: 5),
                InkWell(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      locale: Get.locale,
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setStateDialog(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat.yMMMMEEEEd(
                            Get.locale?.languageCode ?? 'es',
                          ).format(selectedDate),
                        ),
                        Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // --- Selectores de Hora ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CustomText(
                          //   text: "Inicio:",
                          //   type: CustomTextType.subtitulo,
                          // ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: startTime,
                                  );
                              if (pickedTime != null &&
                                  pickedTime != startTime) {
                                setStateDialog(() {
                                  startTime = pickedTime;
                                  final startDateTime = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    startTime.hour,
                                    startTime.minute,
                                  );
                                  final endDateTime = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    endTime.hour,
                                    endTime.minute,
                                  );
                                  if (startDateTime.isAfter(endDateTime) ||
                                      startDateTime.isAtSameMomentAs(
                                        endDateTime,
                                      )) {
                                    endTime = TimeOfDay.fromDateTime(
                                      startDateTime.add(Duration(hours: 1)),
                                    );
                                  }
                                });
                              }
                            },
                            child: Container(
                              /* ... igual que en add ... */
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(startTime.format(context)),
                                  Icon(Icons.access_time, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CustomText(
                          //   text: "Fin:",
                          //   type: CustomTextType.subtitulo,
                          // ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: endTime,
                                  );
                              if (pickedTime != null && pickedTime != endTime) {
                                final startDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  startTime.hour,
                                  startTime.minute,
                                );
                                final proposedEndDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                if (proposedEndDateTime.isAfter(
                                  startDateTime,
                                )) {
                                  setStateDialog(() {
                                    endTime = pickedTime;
                                  });
                                } else {
                                  Get.snackbar(
                                    "Hora Inválida",
                                    "La hora de fin debe ser posterior a la hora de inicio.",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            },
                            child: Container(
                              /* ... igual que en add ... */
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(endTime.format(context)),
                                  Icon(Icons.access_time_filled, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // --- Selector de Color ---
                // CustomText(text: "Color:", type: CustomTextType.subtitulo),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      predefinedColors.map((color) {
                        return InkWell(
                          onTap: () {
                            setStateDialog(() {
                              eventColor = color;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    eventColor.toARGB32() == color.toARGB32()
                                        ? Theme.of(context).primaryColorDark
                                        : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                // Opcional: flutter_colorpicker (igual que en add)
              ],
            ),
          );
        },
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        ),
        child: Text("Actualizar", style: TextStyle(fontSize: 16)),
        onPressed: () {
          if (titleController.text.isNotEmpty) {
            final finalStartTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              startTime.hour,
              startTime.minute,
            );
            final finalEndTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              endTime.hour,
              endTime.minute,
            );

            if (finalEndTime.isBefore(finalStartTime) ||
                finalEndTime.isAtSameMomentAs(finalStartTime)) {
              Get.snackbar(
                "Error de Horas",
                "La hora de fin debe ser posterior a la hora de inicio.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }

            final updatedEvent = Event(
              id:
                  eventToEdit
                      .id, // MUY IMPORTANTE: Pasar el ID del evento original
              title: titleController.text,
              description:
                  descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
              startTime: finalStartTime,
              endTime: finalEndTime,
              color: eventColor,
              location:
                  eventToEdit
                      .location, // Conservar otros campos si no se editan aquí
            );
            // print(
            //   "Intentando actualizar evento: ${updatedEvent.toMap()} con ID: ${updatedEvent.id}",
            // );
            controller.updateExistingEvent(updatedEvent);
            Get.back(); // Cerrar diálogo
          } else {
            Get.snackbar(
              "Error",
              "El título no puede estar vacío.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
      cancel: TextButton(child: Text("Cancelar"), onPressed: () => Get.back()),
    );
  }

  void _confirmDeleteEvent(
    BuildContext context,
    Event eventToDelete,
    AgendaController controller,
  ) {
    // Pasamos el evento y el controller
    Get.defaultDialog(
      title: "Confirmar Eliminación",
      titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText:
          "¿Estás seguro de que quieres eliminar el evento '${eventToDelete.title}'?",
      middleTextStyle: TextStyle(fontSize: 16),
      backgroundColor:
          Theme.of(
            context,
          ).scaffoldBackgroundColor, // Usa el color de fondo del diálogo del tema
      radius: 15.0, // Bordes redondeados
      // Opción 1: Botones de texto simples
      // confirm: TextButton(
      //   style: TextButton.styleFrom(
      //     foregroundColor: Colors.red, // Color del texto
      //   ),
      //   child: Text("Eliminar", style: TextStyle(fontWeight: FontWeight.bold)),
      //   onPressed: () {
      //     if (eventToDelete.id != null) {
      //       controller.removeEvent(eventToDelete.id!, eventToDelete.title);
      //       Get.back(); // Cierra el diálogo de confirmación
      //     } else {
      //        Get.back(); // Cierra el diálogo
      //        Get.snackbar("Error", "No se pudo eliminar el evento: ID no encontrado.", snackPosition: SnackPosition.BOTTOM);
      //     }
      //   },
      // ),
      // cancel: TextButton(
      //   child: Text("Cancelar"),
      //   onPressed: () => Get.back(),
      // ),

      // Opción 2: Botones más estilizados (como en Get.dialog)
      actions: [
        TextButton(
          child: Text(
            "Cancelar",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent, // Color de fondo del botón
            foregroundColor: Colors.white, // Color del texto del botón
          ),
          child: Text("Eliminar", style: TextStyle(fontSize: 16)),
          onPressed: () {
            if (eventToDelete.id == null || eventToDelete.id!.isEmpty) {
              Get.back(); // Cierra el diálogo
              Get.snackbar(
                "Error de Eliminación",
                "No se pudo eliminar el evento: ID de evento no válido o no encontrado.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              // print(
              //   "Error: Intento de eliminar evento con ID nulo o vacío. Título: ${eventToDelete.title}",
              // );
              return;
            }

            // print(
            //   "Eliminando evento con ID: ${eventToDelete.id} y Título: ${eventToDelete.title}",
            // );
            controller.removeEvent(eventToDelete.id!, eventToDelete.title);
            Get.back(); // Cierra el diálogo de confirmación
          },
        ),
      ],
    );
  }
}

// Extensión para capitalizar (si no la tienes ya en tu controller o globalmente)
// extension StringExtension on String {
//   String capitalizeFirst() {
//     if (isEmpty) return "";
//     return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
//   }
// }

// Necesitarás esta función si no está definida globalmente o en TableCalendar
// bool isSameDay(DateTime? a, DateTime? b) {
//   if (a == null || b == null) {
//     return false;
//   }
//   return a.year == b.year && a.month == b.month && a.day == b.day;
// }
