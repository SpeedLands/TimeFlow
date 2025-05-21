import "package:timeflow/global/custom_text_formfield.dart";
import "package:timeflow/modules/auth/controller.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../global/custom_text.dart";

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  LoginPage({super.key});

  // Definimos los colores principales para fácil acceso y modificación
  static const Color primaryColor = Colors.blue; // Azul principal
  static const Color accentColor =
      Colors.lightBlueAccent; // Un azul más claro para acentos
  static const Color backgroundColor = Color(0xFFF5F5F5); // whitesmoke
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColorPrimary = Color(
    0xFF333333,
  ); // Gris oscuro para texto principal
  static const Color textColorSecondary = Color(
    0xFF757575,
  ); // Gris más claro para texto secundario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Fondo whitesmoke
      body:
          MediaQuery.of(context).size.width > 800
              ? buildDesktopLayout(context)
              : buildMobileLayout(context),
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Fondo whitesmoke
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
        ), // Aumentamos padding
        child: Center(
          child: SingleChildScrollView(
            child: buildForm(context, width: double.infinity),
          ),
        ),
      ),
    );
  }

  Widget buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Sección visual izquierda (Calendario Temático)
        Expanded(
          child: Container(
            color: backgroundColor, // Fondo whitesmoke para la sección
            child: Stack(
              children: [
                // Formas decorativas sutiles en tonos azules
                Positioned(
                  top: 100,
                  right: 50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.3),
                          accentColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -80,
                  left: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  right: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                // Iconos temáticos de calendario
                Positioned(
                  bottom: 200,
                  right: 30,
                  child: Icon(
                    Icons.schedule,
                    size: 100,
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                Positioned(
                  top:
                      150, // Ajustado para no superponerse tanto con el icono principal
                  left: 60,
                  child: Icon(
                    Icons.event_note,
                    size: 120,
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                // Contenido principal
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 1),
                        tween: Tween(begin: 0.8, end: 1.0),
                        curve: Curves.elasticOut, // Una curva más juguetona
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Icon(
                              Icons
                                  .calendar_month, // Icono principal de calendario
                              size: 130,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "TimeFlow", // Nombre de la aplicación
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Organiza tu tiempo, sin esfuerzo.\nPlanifica, gestiona y mantente productivo.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: textColorSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Formulario derecha
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                width: 450, // Ancho ajustado para el formulario
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 50.0,
                ), // Mayor padding interno
                decoration: BoxDecoration(
                  color: cardBackgroundColor, // Fondo blanco para el formulario
                  borderRadius: BorderRadius.circular(
                    16.0,
                  ), // Bordes más redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(
                        alpha: 0.2,
                      ), // Sombra más sutil
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: buildForm(
                  context,
                  width: double.infinity,
                ), // Ancho del formulario se adapta al contenedor
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildForm(BuildContext context, {required double width}) {
    // Ancho adaptable para el botón dentro del form
    double buttonWidth = MediaQuery.of(context).size.width > 800 ? 370 : width;

    return SingleChildScrollView(
      child: Column(
        // Eliminamos Center ya que el contenedor padre ya centra
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Estirar elementos horizontalmente
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 30.0,
            ), // Más espacio debajo del título
            child: CustomText(
              text: "Bienvenido de nuevo",
              type:
                  CustomTextType.subtitulo, // Un tamaño de título más estándar
              textAlign: TextAlign.center,
              color: textColorPrimary, // Texto oscuro sobre fondo claro
            ),
          ),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextFormField(
                  controller: emailController,
                  type: TextInputType.emailAddress,
                  hint: "Correo Electrónico",
                  inputType: InputValidationType.email,
                  // Estilos para los campos de texto (opcional, ya que CustomTextFormField podría tener los suyos)
                  // textStyle: TextStyle(color: textColorPrimary),
                  // hintStyle: TextStyle(color: textColorSecondary),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, ingresa un correo electrónico.";
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    ).hasMatch(value)) {
                      return "Por favor, ingresa un correo electrónico válido.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  type: TextInputType.visiblePassword,
                  hint: "Contraseña",
                  inputType: InputValidationType.password,
                  controller: passwordController,
                  isPassword: true,
                  // textStyle: TextStyle(color: textColorPrimary),
                  // hintStyle: TextStyle(color: textColorSecondary),
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
                const SizedBox(height: 30), // Más espacio antes del botón
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      authController.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Botón azul
                    foregroundColor: Colors.white, // Texto blanco en el botón
                    minimumSize: Size(buttonWidth, 50),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ), // Padding vertical
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Bordes redondeados para el botón
                    ),
                    elevation: 5, // Sombra para el botón
                  ),
                  child: const CustomText(
                    // Usamos CustomText para consistencia si es necesario
                    text: "Iniciar Sesión",
                    type:
                        CustomTextType
                            .parrafo, // Un tipo específico para botones si lo tienes
                    color: Colors.white, // Aseguramos color blanco
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Get.toNamed("/register");
            },
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            child: const CustomText(
              text: "¿No tienes cuenta? Regístrate",
              type: CustomTextType.parrafo,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  void showPasswordResetDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: CustomText(
          text: "Recuperar Contraseña",
          type: CustomTextType.parrafo,
          color: textColorPrimary,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text:
                  "Ingresa tu correo electrónico para enviar las instrucciones de recuperación.",
              type: CustomTextType.parrafo,
              color: textColorSecondary,
            ),
            const SizedBox(height: 20),
            TextField(
              // Usamos TextField estándar aquí, o podrías usar tu CustomTextFormField
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Correo electrónico",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: primaryColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: CustomText(
              text: "Cancelar",
              type: CustomTextType.parrafo,
              color: textColorSecondary,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (resetEmailController.text.isNotEmpty) {
                // Validar email si es necesario antes de llamar a authController
                if (RegExp(
                  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                ).hasMatch(resetEmailController.text.trim())) {
                  authController.resetPassword(
                    resetEmailController.text.trim(),
                  );
                  Get.back(); // Cierra el diálogo
                  // Opcional: Muestra un SnackBar de confirmación
                  Get.snackbar(
                    "Solicitud Enviada",
                    "Si el correo está registrado, recibirás un enlace para reestablecer tu contraseña.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: primaryColor,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    "Error",
                    "Por favor, ingresa un correo electrónico válido.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              } else {
                Get.snackbar(
                  "Campo Vacío",
                  "Por favor, ingresa tu correo electrónico.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orangeAccent,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const CustomText(
              text: "Enviar",
              type: CustomTextType.parrafo,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
