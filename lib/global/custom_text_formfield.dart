import "package:flutter/material.dart";

enum InputValidationType {
  lettersWithAccentsAndSpaces,
  numbers,
  password,
  email,
  phone,
  address,
  search,
}

class CustomTextFormField extends StatefulWidget {
  final TextInputType type;
  final bool isPassword;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final InputValidationType inputType;
  final String hint;
  final String? labelText; // Nuevo: Para el label flotante
  final IconData? prefixIcon; // Nuevo: Para el icono prefijo
  final String? errorText;
  final int maxLines;
  final int maxLength;
  final String? Function(String?)? validator;
  final Color accentColor; // Nuevo: Para personalizar el color de acento
  final Color fillColor; // Nuevo: Para personalizar el color de fondo
  final Color textColor; // Nuevo: Para personalizar el color del texto
  final Color hintColor; // Nuevo: Para personalizar el color del hint
  final Color errorColor; // Nuevo: Para personalizar el color del error

  const CustomTextFormField({
    super.key,
    required this.type,
    this.isPassword = false,
    required this.controller,
    this.onChanged,
    required this.inputType,
    required this.hint,
    this.labelText, // Añadido
    this.prefixIcon, // Añadido
    this.errorText,
    this.maxLines = 1,
    this.maxLength = 100,
    this.validator,
    this.accentColor = Colors.tealAccent, // Color de acento por defecto
    this.fillColor = const Color(0xff222222), // Un gris oscuro más suave
    this.textColor = Colors.white,
    this.hintColor = Colors.grey,
    this.errorColor = Colors.redAccent,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;
  String? _internalErrorText;
  late FocusNode _focusNode;

  // Expresiones regulares para validación
  final Map<InputValidationType, RegExp> _validationPatterns = {
    InputValidationType.lettersWithAccentsAndSpaces: RegExp(
      r"^[\p{L}\s]*$",
      unicode: true,
    ),
    InputValidationType.numbers: RegExp(r"^\d+$"),
    InputValidationType.email: RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    ),
    InputValidationType.address: RegExp(r"^[A-Za-záéíóúÁÉÍÓÚñÑ0-9\s,.-]+$"),
    InputValidationType.phone: RegExp(r"^\d{10}$"),
    InputValidationType.password: RegExp(
      r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$",
    ),
    InputValidationType.search: RegExp(
      r"^[A-Za-záéíóúÁÉÍÓÚñÑ0-9\s.,:;+\-_%#@!?&$]*$",
    ),
  };

  // Mensajes de error personalizados
  final Map<InputValidationType, String> _errorMessages = {
    InputValidationType.lettersWithAccentsAndSpaces:
        "Solo se permiten letras y espacios.",
    InputValidationType.numbers: "Solo se permiten números.",
    InputValidationType.email: "Ingrese un correo electrónico válido.",
    InputValidationType.address: "Ingrese una dirección válida.",
    InputValidationType.phone:
        "Ingrese un número de teléfono válido (10 dígitos).",
    InputValidationType.password:
        "La contraseña debe cumplir con los requisitos de seguridad.",
    InputValidationType.search:
        "El término de búsqueda contiene caracteres no permitidos.",
  };

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _internalErrorText = widget.errorText;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {}); // Re-render to update labelStyle color on focus change
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Validar la entrada del usuario
  String? _validateInput(String? value) {
    if (widget.inputType == InputValidationType.search &&
        (value == null || value.isEmpty)) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return "Este campo es obligatorio.";
    }

    final regex = _validationPatterns[widget.inputType];
    if (regex != null && !regex.hasMatch(value)) {
      return _errorMessages[widget.inputType] ?? "Entrada no válida.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: widget.textColor, fontSize: 16.0);
    final hintStyle = TextStyle(color: widget.hintColor, fontSize: 16.0);
    final labelStyle = TextStyle(
      color: _focusNode.hasFocus ? widget.accentColor : widget.hintColor,
      fontSize: 16.0,
    );
    final errorStyle = TextStyle(color: widget.errorColor, fontSize: 12.0);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ), // Aumentado padding vertical
      child: TextFormField(
        focusNode: _focusNode,
        keyboardType: widget.type,
        maxLength: widget.maxLength,
        obscureText: widget.isPassword ? _obscureText : false,
        controller: widget.controller,
        onChanged: (value) {
          setState(() {
            // Usamos el validador interno o el provisto por el widget
            _internalErrorText = (widget.validator ?? _validateInput)(value);
          });
          widget.onChanged?.call(value);
        },
        validator: widget.validator ?? _validateInput,
        maxLines: widget.maxLines,
        style: textStyle,
        cursorColor: widget.accentColor,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 15.0,
          ), // Ajuste de padding interno
          labelText: widget.labelText,
          labelStyle: labelStyle,
          hintText: widget.hint,
          hintStyle: hintStyle,
          errorText: _internalErrorText,
          errorStyle: errorStyle,
          counterStyle: TextStyle(
            color: widget.hintColor.withValues(alpha: 0.7),
          ),
          filled: true,
          fillColor: widget.fillColor,
          prefixIcon:
              widget.prefixIcon != null
                  ? Icon(
                    widget.prefixIcon,
                    color:
                        _focusNode.hasFocus
                            ? widget.accentColor
                            : widget.hintColor,
                  )
                  : null,
          suffixIcon:
              widget.isPassword
                  ? _buildVisibilityIcon()
                  : (widget.inputType == InputValidationType.search
                      ? Icon(Icons.search, color: widget.hintColor)
                      : null),
          border: OutlineInputBorder(
            // Borde por defecto
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: widget.hintColor.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            // Borde cuando está habilitado y sin foco
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: widget.hintColor.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            // Borde cuando tiene foco
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: widget.accentColor, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            // Borde cuando hay error y sin foco
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: widget.errorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            // Borde cuando hay error y con foco
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: widget.errorColor, width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget? _buildVisibilityIcon() {
    return IconButton(
      icon: Icon(
        _obscureText
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: _focusNode.hasFocus ? widget.accentColor : widget.hintColor,
        semanticLabel:
            _obscureText ? "Mostrar contraseña" : "Ocultar contraseña",
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}
