import "package:timeflow/modules/auth/controller.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'widgets/auth_visual_panel.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Los colores y estilos se obtienen del tema global
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body:
          MediaQuery.of(context).size.width > 800
              ? buildDesktopLayout(context)
              : buildMobileLayout(context),
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: buildForm(context, width: double.infinity),
          ),
        ),
      ),
    );
  }

  Widget buildDesktopLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Sección visual izquierda
        const Expanded(
          child: AuthVisualPanel(
            icon: Icons.calendar_month,
            title: "TimeFlow",
            subtitle: "Organiza tu tiempo, sin esfuerzo.",
          ),
        ),

        // Formulario derecha
        Expanded(
          child: Center(
            child: Container(
              width: 450,
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
              decoration: BoxDecoration(
                color: colorScheme.background,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: buildForm(context, width: double.infinity),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildForm(BuildContext context, {required double width}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Text(
              "Bienvenido de nuevo",
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: "Correo Electrónico"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, ingresa un correo electrónico.";
                    }
                    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                      return "Por favor, ingresa un correo electrónico válido.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Contraseña"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, ingresa una contraseña.";
                    }
                    if (value.length < 6) {
                      return "La contraseña debe tener al menos 6 caracteres.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      try {
                        await authController.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        Get.offAllNamed("/home"); // Navega a home en éxito
                      } catch (e) {
                        Get.snackbar(
                          "Error de autenticación",
                          e.toString().replaceFirst("Exception: ", ""),
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: colorScheme.error,
                          colorText: colorScheme.onError,
                        );
                      }
                    }
                  },
                  child: const Text("Iniciar Sesión"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Get.toNamed("/register"),
            child: Text(
              "¿No tienes cuenta? Regístrate",
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  void showPasswordResetDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    Get.dialog(
      AlertDialog(
        title: Text("Recuperar Contraseña", style: textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Ingresa tu correo para enviar las instrucciones de recuperación.",
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "Correo electrónico"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resetEmailController.text.isNotEmpty) {
                if (RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(resetEmailController.text.trim())) {
                  try {
                    await authController.resetPassword(resetEmailController.text.trim());
                    Get.back();
                    Get.snackbar(
                      "Solicitud Enviada",
                      "Si el correo está registrado, recibirás un enlace.",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } catch (e) {
                    Get.snackbar(
                      "Error",
                      e.toString().replaceFirst("Exception: ", ""),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                } else {
                  Get.snackbar(
                    "Error",
                    "Por favor, ingresa un correo electrónico válido.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }
}
