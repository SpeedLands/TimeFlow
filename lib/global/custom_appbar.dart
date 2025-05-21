import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Necesario para el fallback del título del mes
import 'package:table_calendar/table_calendar.dart';
import 'package:timeflow/global/custom_text.dart';
import 'package:timeflow/modules/agenda/controller.dart';
import 'package:timeflow/modules/agenda/widgets/event_search_delegate.dart';

import '../data/model/agenda_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AgendaController controller = Get.find<AgendaController>();

  CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Determinar colores de iconos y texto basados en el tema del AppBar o el tema general
    final Color iconColor =
        theme.appBarTheme.iconTheme?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);
    final Color titleTextColor =
        theme.appBarTheme.titleTextStyle?.color ?? iconColor;

    return AppBar(
      elevation:
          theme.appBarTheme.elevation ??
          1.0, // Usar elevación del tema o default
      backgroundColor:
          theme.appBarTheme.backgroundColor ??
          theme.colorScheme.surface, // Usar color del tema o default
      leading: Builder(
        // Builder es necesario para obtener el Scaffold.of(context) correcto
        builder:
            (context) => IconButton(
              icon: Icon(Icons.menu, color: iconColor),
              tooltip: "Abrir menu lateral", // Tooltip estándar
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      title: Obx(() {
        // Fallback si mesSeleccionadoNombre está vacío al inicio
        String currentMonthDisplay = controller.mesSeleccionadoNombre.value;
        if (currentMonthDisplay.isEmpty) {
          // Asegúrate de tener DateFormat.MMMM inicializado para el idioma
          // Ejemplo: DateFormat.MMMM(Get.locale?.languageCode ?? 'es').format(controller.focusDay.value)
          // Para ser más robusto, puedes usar el DateFormat directamente del controller si ya lo tienes
          currentMonthDisplay =
              StringExtension(
                DateFormat.MMMM(
                  Get.locale?.languageCode ?? 'es',
                ).format(controller.focusDay.value),
              ).capitalizeFirst();
        }

        return TextButton.icon(
          onPressed: controller.toggleMesesDropdown,
          style: TextButton.styleFrom(
            foregroundColor: titleTextColor,
            // Podrías considerar un splashFactory si el splash por defecto es muy intrusivo
            // splashFactory: NoSplash.splashFactory,
          ),
          icon: RotationTransition(
            turns: Tween(
              begin: 0.0,
              end: 0.5, // Medio giro para la flecha
            ).animate(controller.iconRotationController),
            child: Icon(Icons.arrow_drop_down, color: titleTextColor),
          ),
          label: CustomText(
            text: currentMonthDisplay, // Usar el valor con fallback
            type:
                CustomTextType
                    .subtitulo, // Asume que CustomText maneja su propio estilo/color o hereda
            // Si CustomText no hereda color, puedes pasarlo:
            // style: TextStyle(color: titleTextColor),
          ),
        );
      }),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: iconColor),
          tooltip: "Buscar",
          onPressed: () async {
            // print("Buscar presionado");
            // Lanza el SearchDelegate
            final Event? selectedEvent = await showSearch<Event?>(
              context: context,
              delegate: EventSearchDelegate(),
            );

            if (selectedEvent != null) {
              // El usuario seleccionó un evento, y el SearchDelegate ya llamó a
              // agendaController.goToEventDate(selectedEvent)
              // print(
              //   "Evento seleccionado desde búsqueda: ${selectedEvent.title}",
              // );
            } else {
              // El usuario cerró la búsqueda sin seleccionar nada
              // Opcionalmente, limpia los resultados si no lo hizo el delegate
              controller.clearSearch();
              // print("Búsqueda cerrada sin selección.");
            }
          },
        ),
        // Botón "Hoy": Es mejor usar un icono o texto estático para evitar reconstrucciones
        // o si el número es esencial, que venga de un Rx que solo cambie 1 vez al día.
        // Opción 1: Icono (como Google Calendar)
        IconButton(
          icon: Icon(Icons.today_outlined, color: iconColor),
          tooltip: "Hoy", // O un texto más descriptivo como "Ir a hoy"
          onPressed: () {
            controller.focusDay.value = DateTime.now();
            // Si también quieres que se seleccione el día de hoy en el calendario:
            if (controller.selectedDay.value == null ||
                !isSameDay(controller.selectedDay.value!, DateTime.now())) {
              controller.selectedDay.value = DateTime.now();
            }
            // print("Hoy seleccionado: ${controller.focusDay.value}");
          },
        ),
        // Opción 2: Si realmente necesitas el día del mes (y has gestionado la actualización en el controller)
        // Obx(() => TextButton(
        //   onPressed: () {
        //     controller.focusDay.value = DateTime.now();
        //     // ...
        //   },
        //   style: TextButton.styleFrom(
        //     foregroundColor: titleTextColor,
        //     // ... (tu estilo de borde)
        //   ),
        //   child: CustomText(
        //     text: controller.currentDayOfMonth.value, // Necesitarías un RxString en el controller
        //     type: CustomTextType.parrafo,
        //   ),
        // )),
        SizedBox(width: 4), // Pequeño espaciado
        GestureDetector(
          onTap: () {
            // print("Perfil presionado");
            // Lógica para ir al perfil, ej: Get.to(() => ProfileScreen());
          },
          child: Tooltip(
            message: "Perfil", // Tooltip para el avatar
            child: Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                right: 12.0,
              ), // Ajustar padding
              child: CircleAvatar(
                radius: 18,
                backgroundColor:
                    theme.colorScheme.secondaryContainer, // Color del tema
                child: Icon(
                  Icons.person_outline, // Icono de perfil más estándar
                  color:
                      theme.colorScheme.onSecondaryContainer, // Color del tema
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Estándar para AppBar
}

// Pequeña extensión para capitalizar la primera letra (si no la tienes globalmente)
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
