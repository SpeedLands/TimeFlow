import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeflow/modules/agenda/controller.dart';
import 'package:timeflow/global/custom_text.dart';
import 'package:timeflow/modules/auth/controller.dart';

class CustomSidebar extends StatelessWidget {
  final AgendaController controller = Get.find<AgendaController>();
  final AuthController authController = Get.find<AuthController>();

  CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Navegación lateral',
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.calendar_today, size: 36, color: Colors.blueGrey),
                const SizedBox(height: 8),
                CustomText(text: "TimeFlow", type: CustomTextType.titulo),
                const SizedBox(height: 24),
                Divider(),
                _sectionLabel("Vista"),
                SidebarOption(
                  controller: controller,
                  label: "Semana",
                  icon: Icons.view_week,
                  format: CalendarFormat.week,
                  onTap: () => controller.calendarFormat(CalendarFormat.week),
                ),
                SidebarOption(
                  controller: controller,
                  label: "2 Semanas",
                  icon: Icons.calendar_view_day,
                  format: CalendarFormat.twoWeeks,
                  onTap:
                      () => controller.calendarFormat(CalendarFormat.twoWeeks),
                ),
                SidebarOption(
                  controller: controller,
                  label: "Mes",
                  icon: Icons.calendar_month,
                  format: CalendarFormat.month,
                  onTap: () => controller.calendarFormat(CalendarFormat.month),
                ),
              ],
            ),
            Column(
              children: [
                Divider(),
                _sectionLabel("Cuenta"),
                SidebarOption(
                  controller: controller,
                  label: "Cerrar sesión",
                  icon: Icons.login,
                  format: null,
                  onTap: () {
                    authController.logout();
                    Get.offAndToNamed("/login");
                    // Diálogo de login o acción
                  },
                ),
                SidebarOption(
                  controller: controller,
                  label: "Configuraciones",
                  icon: Icons.settings,
                  format: null,
                  onTap: () {
                    Get.back();
                    Get.toNamed("/settings");
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.blueGrey.shade400,
          ),
        ),
      ),
    );
  }
}

class SidebarOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final CalendarFormat? format;
  final AgendaController controller;
  final IconData icon;

  const SidebarOption({
    super.key,
    required this.label,
    required this.onTap,
    required this.format,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = format == controller.calendarFormat.value;

      return Semantics(
        button: true,
        label: label,
        selected: isSelected,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.blueGrey,
            ),
            title: CustomText(text: label, type: CustomTextType.subtitulo),
            onTap: onTap,
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: isSelected ? Colors.blueGrey : Colors.transparent,
            selected: isSelected,
            selectedTileColor: Colors.blueGrey,
            selectedColor: Colors.white,
          ),
        ),
      );
    });
  }
}
