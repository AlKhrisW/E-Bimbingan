import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3461FF); // Warna Biru Utama (dari tombol Figma)
  static const Color secondaryColor = Color(0xFF42A5F5); 
  static const Color errorColor = Color(0xFFFF0000); // Merah untuk error/lupa password

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontFamily: 'Roboto', fontSize: 24),
      titleSmall: TextStyle(fontFamily: 'Roboto', fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        elevation: 5,
        minimumSize: const Size(double.infinity, 55),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2.0),
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
    ),
  );
}