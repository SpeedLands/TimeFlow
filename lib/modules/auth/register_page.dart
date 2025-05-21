import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timeflow/data/model/user_model.dart"; // Asegúrate que este modelo es necesario aquí
import "package:timeflow/global/custom_text.dart";
import "package:timeflow/global/custom_text_formfield.dart";
import "package:timeflow/modules/auth/controller.dart";

class SignupPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AuthController controller = Get.find<AuthController>();

  SignupPage({super.key});

  // Colores consistentes con LoginPage
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.lightBlueAccent;
  static const Color backgroundColor = Color(0xFFF5F5F5); // whitesmoke
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColorPrimary = Color(0xFF333333);
  static const Color textColorSecondary = Color(0xFF757575);
  static const Color errorColor = Colors.redAccent;
  static const Color successColor = Colors.green; // Un verde suave para éxito

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        // AppBar sutil para volver o título
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Get.back(),
        ),
        title: CustomText(
          text: "Crear Cuenta",
          type: CustomTextType.titulo, // O el que uses para títulos de AppBar
          color: primaryColor,
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
    // Invertimos el orden para tener el formulario a la derecha, como en LoginPage
    return Row(
      children: [
        // Sección visual izquierda (Calendario Temático)
        Expanded(
          child: Container(
            color: backgroundColor,
            child: Stack(
              children: [
                // Formas decorativas sutiles
                Positioned(
                  top: 100,
                  left: 50, // Cambiado de right a left
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
                  right: -80, // Cambiado de left a right
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                // Iconos temáticos
                Positioned(
                  bottom: 150,
                  left: 40,
                  child: Icon(
                    Icons.app_registration, // Icono de registro
                    size: 100,
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                Positioned(
                  top: 200,
                  right: 60,
                  child: Icon(
                    Icons.edit_calendar, // Icono de editar calendario
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
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Icon(
                              Icons.person_add_alt_1, // Icono de añadir usuario
                              size: 130,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Únete a TimeFlow",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Regístrate para organizar tu tiempo\ny maximizar tu productividad.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: textColorSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                width: 450, // Ancho ajustado
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 50.0,
                ),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: buildForm(context, width: double.infinity),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildForm(BuildContext context, {required double width}) {
    double buttonWidth = MediaQuery.of(context).size.width > 800 ? 370 : width;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: CustomText(
              text: "Crea una nueva cuenta",
              type: CustomTextType.titulo, // Ajusta según tus CustomTextType
              textAlign: TextAlign.center,
              color: textColorPrimary,
            ),
          ),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextFormField(
                  hint: "Correo electrónico",
                  controller: emailController,
                  inputType: InputValidationType.email,
                  type: TextInputType.emailAddress,
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
                const SizedBox(height: 10),
                CustomTextFormField(
                  type: TextInputType.visiblePassword,
                  controller: passwordController,
                  hint: "Contraseña",
                  isPassword: true,
                  inputType: InputValidationType.password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, ingresa una contraseña.";
                    }
                    // Regex consistente con PasswordRequirementsIndicator
                    if (!RegExp(
                      r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$",
                    ).hasMatch(value)) {
                      return "La contraseña no cumple los requisitos."; // Mensaje genérico
                    }
                    return null;
                  },
                ),
                PasswordRequirementsIndicator(
                  passwordController: passwordController,
                  primaryColor: primaryColor, // Pasar colores
                  errorColor: errorColor,
                  successColor: successColor,
                  textColor: textColorSecondary,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  type: TextInputType.visiblePassword,
                  controller: confirmPasswordController,
                  hint: "Confirmar Contraseña",
                  isPassword: true,
                  inputType: InputValidationType.password,
                  // errorText: "Las contraseñas no coinciden.", // Se maneja con el validador
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
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(buttonWidth, 50),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      // Asegúrate que UserData solo necesite el email para el registro inicial
                      // o que el UID se genere/maneje correctamente en el backend/controller.
                      controller.register(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        UserData(
                          uid: "",
                          email: emailController.text.trim(),
                        ), // uid vacío es común antes de que Firebase lo genere
                      );
                    }
                  },
                  child: const CustomText(
                    text: "Registrarse",
                    type: CustomTextType.parrafo,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Get.toNamed("/login");
                  },
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                  child: RichText(
                    // Para combinar estilos si es necesario
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "¿Ya tienes una cuenta? ",
                      style: TextStyle(
                        color: textColorSecondary,
                        fontSize: 14,
                      ), // Usa tus estilos de CustomText
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Iniciar Sesión',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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
  final Color primaryColor;
  final Color errorColor;
  final Color successColor;
  final Color textColor;

  const PasswordRequirementsIndicator({
    super.key,
    required this.passwordController,
    required this.primaryColor,
    required this.errorColor,
    required this.successColor,
    required this.textColor,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_outline : Icons.highlight_off,
            color: isMet ? widget.successColor : widget.errorColor,
            size: 18, // Tamaño ajustado
          ),
          const SizedBox(width: 8),
          CustomText(
            // Usar CustomText si se prefiere
            text: text,
            type: CustomTextType.parrafo, // O un tipo pequeño que tengas
            color:
                isMet
                    ? widget.textColor.withValues(alpha: 0.8)
                    : widget.errorColor.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }
}
