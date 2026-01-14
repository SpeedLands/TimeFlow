import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeflow/modules/agenda/controller.dart';

class MonthSelectorWidget extends StatefulWidget {
  const MonthSelectorWidget({super.key});

  @override
  State<MonthSelectorWidget> createState() => _MonthSelectorWidgetState();
}

class _MonthSelectorWidgetState extends State<MonthSelectorWidget>
    with TickerProviderStateMixin {
  final AgendaController controller = Get.find<AgendaController>();
  late AnimationController _iconRotationController;
  bool _mostrarMesesDropdown = false;

  @override
  void initState() {
    super.initState();
    _iconRotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  void _toggleMesesDropdown() {
    setState(() {
      _mostrarMesesDropdown = !_mostrarMesesDropdown;
      if (_mostrarMesesDropdown) {
        _iconRotationController.forward();
      } else {
        _iconRotationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Aquí se construiría la interfaz de usuario del selector de mes,
    // usando _toggleMesesDropdown, _mostrarMesesDropdown,
    // y el _iconRotationController.
    // Como no tengo el código de la vista, este es un placeholder.
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleMesesDropdown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                    controller.mesSeleccionadoNombre.value,
                    style: Theme.of(context).textTheme.titleLarge,
                  )),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_iconRotationController),
                child: const Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
        ),
        if (_mostrarMesesDropdown)
          // Aquí iría el menú desplegable de meses
          Container(),
      ],
    );
  }

  @override
  void dispose() {
    _iconRotationController.dispose();
    super.dispose();
  }
}
