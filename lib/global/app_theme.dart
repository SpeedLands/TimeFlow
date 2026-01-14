import 'package:flutter/material.dart';

// Paleta de colores inspirada en Google Keep (Material Design 3)
// Usaremos un esquema de color basado en semillas (seed-based color scheme)
// para generar tonos claros y oscuros consistentes.

const _seedColor = Color(0xFFFFC107); // Ámbar como color principal

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      primary: _seedColor,
      onPrimary: Colors.black, // Texto/iconos sobre el color primario
      secondary: Colors.blueGrey[100]!,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      background: Colors.grey[50]!,
      onBackground: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[50],
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      // Definir estilos de texto que se usarán en la app
      headlineLarge: TextStyle(fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16),
      labelLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _seedColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.blueGrey[50],
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      primary: _seedColor,
      onPrimary: Colors.black,
      secondary: Colors.blueGrey[800]!,
      onSecondary: Colors.white,
      surface: Colors.grey[900]!,
      onSurface: Colors.white,
      background: Colors.black,
      onBackground: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      labelLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _seedColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.blueGrey[800],
    ),
  );
}
