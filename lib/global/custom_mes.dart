import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeflow/global/custom_text.dart'; // Asumo que CustomText puede tomar un TextStyle
import 'package:timeflow/modules/agenda/controller.dart';

class MesesToggleGetXWidget extends StatelessWidget {
  MesesToggleGetXWidget({super.key});

  // CORRECTO: Usar Get.find() si el controlador ya fue instanciado por un widget padre.
  // Si este es el ÚNICO lugar donde se crea y es específico para este widget y sus hijos,
  // podrías usar Get.lazyPut o Get.put aquí, pero es menos común para un widget tan específico.
  // Lo más probable es que el controlador ya exista.
  final AgendaController controller = Get.find<AgendaController>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String currentLocale = Get.locale?.languageCode ?? 'es';

    // Obtener la lista de meses del controlador (que debería usar intl)
    // Esto asegura que los meses estén en el idioma correcto.
    final List<String> mesesDelAnio = controller.obtenerTodosLosNombresDeMeses(
      currentLocale,
    );

    return Obx(() {
      // Usar AnimatedSwitcher para una transición suave de aparición/desaparición
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SizeTransition(
            // O FadeTransition, ScaleTransition
            sizeFactor: animation,
            axisAlignment: -1.0, // Animar desde arriba
            child: child,
          );
        },
        child:
            !controller.mostrarMesesDropdown.value
                ? const SizedBox.shrink() // No mostrar nada si está oculto
                : Container(
                  // Contenedor para el ListView
                  key: const ValueKey(
                    "mesesListViewContainer",
                  ), // Key para AnimatedSwitcher
                  height:
                      60, // Altura un poco mayor para acomodar padding y bordes
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ), // Padding vertical
                  // Podrías añadir un color de fondo si la transición lo necesita
                  // color: theme.scaffoldBackgroundColor, // O un color sutil
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: mesesDelAnio.length,
                    itemBuilder: (context, index) {
                      final mes = mesesDelAnio[index];
                      final bool isSelected =
                          controller.mesSeleccionadoNombre.value == mes;

                      // Colores basados en el estado de selección y el tema
                      final Color chipColor =
                          isSelected
                              ? theme.colorScheme.primary
                              : theme
                                  .colorScheme
                                  .surfaceContainerHighest; // Un color sutil para no seleccionado
                      final Color borderColor =
                          isSelected
                              ? theme.colorScheme.primary
                              : theme
                                  .colorScheme
                                  .outline; // Color de borde del tema

                      return Padding(
                        // Usar Padding en lugar de Margin en AnimatedContainer para que el InkWell ocupe todo el espacio
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: chipColor,
                            borderRadius: BorderRadius.circular(
                              25,
                            ), // Bordes más redondeados tipo chip
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ]
                                    : [
                                      // Sombra sutil para no seleccionados también, si se desea
                                      BoxShadow(
                                        color: theme.shadowColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap:
                                  () => controller.seleccionarMesDesdeDropdown(
                                    mes,
                                  ),
                              splashColor: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              highlightColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.05),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18, // Más padding horizontal
                                  vertical: 10,
                                ),
                                child: Center(
                                  // Centrar el texto
                                  child: CustomText(
                                    text: mes,
                                    type: CustomTextType.subtitulo,
                                    // Asumiendo que CustomText puede tomar un estilo o color directamente:
                                    // De lo contrario, envuelve CustomText con DefaultTextStyle
                                    // o asegúrate de que CustomText herede el color correctamente.
                                    // Es más explícito pasar el color si CustomText lo soporta.
                                    // Ejemplo si CustomText tiene un parámetro 'color':
                                    // color: textColor,
                                    // O si toma un 'style':
                                    // style: TextStyle(color: textColor, fontWeight: FontWeight.w500 /* o el que corresponda a subtitulo */),
                                    // Si no, puedes envolverlo así para que el color sea correcto:
                                    // DefaultTextStyle(
                                    //   style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                                    //   child: CustomText(text: mes, type: CustomTextType.subtitulo),
                                    // ),
                                    // Por ahora, asumiré que CustomText es suficientemente inteligente o que
                                    // su estilo por defecto se ve bien sobre los colores de fondo.
                                    // Sin embargo, para garantizar el contraste, controlar el color del texto es importante.
                                    // Vamos a SIMULAR que CustomText toma un style:
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        // La SizedBox(height: 10) se puede quitar si el AnimatedSwitcher maneja bien el espacio
        // o si el padding del Container superior ya es suficiente.
        // const SizedBox(height: 10), // Comentado, ajustar según necesidad
      );
    });
  }
}

// Para que la simulación de CustomText funcione, necesitarías que CustomText acepte un `style`:
// Ejemplo de cómo podrías modificar CustomText:
/*
class CustomText extends StatelessWidget {
  final String text;
  final CustomTextType type;
  final TextStyle? style; // Nuevo parámetro opcional

  const CustomText({
    Key? key,
    required this.text,
    required this.type,
    this.style, // Añadido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle;
    // ... tu lógica de switch para `defaultStyle`
    // ...
    // Fusionar estilo por defecto con el estilo proporcionado
    final effectiveStyle = (style == null) ? defaultStyle : defaultStyle.merge(style);
    return Text(text, style: effectiveStyle);
  }
}
*/
