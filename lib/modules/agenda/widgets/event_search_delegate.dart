// event_search_delegate.dart (nuevo archivo)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeflow/data/model/agenda_model.dart';
import 'package:timeflow/modules/agenda/controller.dart';
import 'package:timeflow/global/custom_text.dart'; // Si lo usas para mostrar texto

class EventSearchDelegate extends SearchDelegate<Event?> {
  // Puede devolver el Evento seleccionado o null
  final AgendaController agendaController = Get.find<AgendaController>();

  EventSearchDelegate()
    : super(
        searchFieldLabel: "Buscar eventos...",
      ); // Placeholder para el campo de búsqueda

  @override
  ThemeData appBarTheme(BuildContext context) {
    // Opcional: Personalizar el tema del AppBar de búsqueda
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.colorScheme.surface, // O el color que prefieras
        // iconTheme: theme.iconTheme.copyWith(color: theme.colorScheme.onSurface),
        // titleTextStyle: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
      ),
      inputDecorationTheme:
          searchFieldDecorationTheme ??
          InputDecorationTheme(
            hintStyle: TextStyle(color: theme.hintColor),
            // border: InputBorder.none, // Para un look más minimalista
          ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Acciones para el AppBar (ej: botón de limpiar)
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          tooltip: "Limpiar",
          onPressed: () {
            query = ''; // Limpia el query
            showSuggestions(
              context,
            ); // Muestra sugerencias (o lista vacía) de nuevo
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Widget al inicio del AppBar (ej: botón de regresar)
    return IconButton(
      icon: Icon(Icons.arrow_back),
      tooltip: "Regresar",
      onPressed: () {
        agendaController
            .clearSearch(); // Limpia los resultados en el controller
        close(context, null); // Cierra la búsqueda sin resultado
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Se llama cuando el usuario presiona "buscar" en el teclado (o envía el query)
    // Aquí ya deberías tener los resultados del controller
    // o puedes llamar a agendaController.searchEvents(query) si no lo hiciste en buildSuggestions
    // Por simplicidad, asumimos que buildSuggestions ya actualizó searchResults

    // Llama a searchEvents aquí para asegurar que los resultados estén actualizados
    // al presionar enter/buscar en el teclado.
    agendaController.searchEvents(query);

    return Obx(() {
      // Escucha los cambios en searchResults
      if (agendaController.searchResults.isEmpty && query.isNotEmpty) {
        return Center(
          child: CustomText(
            text: "No se encontraron eventos para '$query'.",
            type: CustomTextType.parrafo,
          ),
        );
      }
      if (agendaController.searchResults.isEmpty && query.isEmpty) {
        return Center(
          child: CustomText(
            text: "Ingresa un término para buscar.",
            type: CustomTextType.parrafo,
          ),
        );
      }
      return _buildSearchResultsList(agendaController.searchResults);
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Se llama mientras el usuario escribe, para mostrar sugerencias
    // Aquí podrías mostrar sugerencias inmediatas o una lista de resultados parciales
    if (query.isEmpty) {
      // Opcional: Mostrar eventos recientes o favoritos si el query está vacío
      // agendaController.clearSearch(); // Asegura que no haya resultados viejos
      // return Center(child: CustomText(text: "Busca por título, descripción...", type: CustomTextType.parrafo));
      if (agendaController.searchResults.isNotEmpty) {
        agendaController.clearSearch();
      }
      return const SizedBox.shrink(); // No mostrar nada si no hay query
    }

    // Actualiza los resultados en el controlador mientras el usuario escribe
    agendaController.searchEvents(query);

    return Obx(() {
      // Escucha los cambios en searchResults
      if (agendaController.isSearching.value &&
          agendaController.searchResults.isEmpty) {
        // Podrías mostrar un indicador de carga si la búsqueda fuera asíncrona y lenta
        // return Center(child: CircularProgressIndicator());
      }
      return _buildSearchResultsList(agendaController.searchResults);
    });
  }

  Widget _buildSearchResultsList(List<Event> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final event = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: event.color,
            child: CustomText(
              text: DateFormat('d').format(event.startTime), // Día del mes
              type: CustomTextType.parrafo,
              color: Colors.white,
            ),
          ),
          title: CustomText(text: event.title, type: CustomTextType.subtitulo),
          subtitle: CustomText(
            text:
                "${DateFormat.yMMMEd('es').format(event.startTime)} (${DateFormat.Hm('es').format(event.startTime)} - ${DateFormat.Hm('es').format(event.endTime)})",
            type: CustomTextType.parrafo,
          ),
          onTap: () {
            // Cuando el usuario selecciona un evento de la lista
            agendaController.goToEventDate(event);
            close(
              context,
              event,
            ); // Cierra la búsqueda y devuelve el evento seleccionado
          },
        );
      },
    );
  }
}
