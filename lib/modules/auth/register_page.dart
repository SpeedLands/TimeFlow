import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timeflow/data/model/user_model.dart";
import "package:timeflow/modules/auth/controller.dart";
import "widgets/auth_visual_panel.dart";

class SignupPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AuthController controller = Get.find<AuthController>();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Crear Cuenta",
          style: TextStyle(color: colorScheme.primary),
        ),
        centerTitle: true,
      ),
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
            icon: Icons.person_add_alt_1,
            title: "Únete a TimeFlow",
            subtitle: "Regístrate para organizar tu tiempo.",
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
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              "Crea una nueva cuenta",
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
                  decoration: const InputDecoration(hintText: "Correo electrónico"),
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
                    if (!RegExp(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$").hasMatch(value)) {
                      return "La contraseña no cumple los requisitos.";
                    }
                    return null;
                  },
                ),
                PasswordRequirementsIndicator(
                  passwordController: passwordController,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Confirmar Contraseña"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, confirma la contraseña.";
                    }
                    if (value != passwordController.text) {
                      return "Las contraseñas no coinciden.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      try {
                        await controller.register(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          UserData(
                            uid: "",
                            email: emailController.text.trim(),
                          ),
                        );
                        Get.snackbar(
                          "Registro Exitoso",
                          "Se ha enviado un correo de verificación.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        Get.offAllNamed("/login"); // Vuelve a login para que inicie sesión
                      } catch (e) {
                        Get.snackbar(
                          "Error de registro",
                          e.toString().replaceFirst("Exception: ", ""),
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: colorScheme.error,
                          colorText: colorScheme.onError,
                        );
                      }
                    }
                  },
                  child: const Text("Registrarse"),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Get.toNamed("/login"),
                  child: Text(
                    "¿Ya tienes una cuenta? Iniciar Sesión",
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordRequirementsIndicator extends StatefulWidget {
  final TextEditingController passwordController;

  const PasswordRequirementsIndicator({
    super.key,
    required this.passwordController,
  });

  @override
  PasswordRequirementsIndicatorState createState() =>
      PasswordRequirementsIndicatorState();
}

class PasswordRequirementsIndicatorState
    extends State<PasswordRequirementsIndicator> {
  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      // Verificar si el widget sigue montado
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String password = widget.passwordController.text;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0), // Pequeño padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequirement("Al menos 8 caracteres", password.length >= 8),
          _buildRequirement(
            "Incluir mayúsculas (A-Z)",
            RegExp(r"[A-Z]").hasMatch(password),
          ),
          _buildRequirement(
            "Incluir minúsculas (a-z)",
            RegExp(r"[a-z]").hasMatch(password),
          ),
          _buildRequirement(
            "Incluir números (0-9)",
            RegExp(r"[0-9]").hasMatch(password),
          ),
          _buildRequirement(
            "Incluir símbolo (@#\$%...)",
            RegExp(r'[\W_]').hasMatch(password),
          ), // \W también cubre _
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_outline : Icons.highlight_off,
            color: isMet ? colorScheme.primary : colorScheme.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: isMet ? colorScheme.onSurface : colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
