import 'package:flutter/material.dart';

class AppTheme {
  // New Colors
  static const Color primaryColor = Color(0xFF93B7BE);    // Soft Blue
  static const Color secondaryColor = Color(0xFF8C9A9E);  // Cool Gray
  static const Color accentColor = Color(0xFF747578);     // Dark Gray
  static const Color backgroundColor = Colors.white;       // Clean White

  // Updated color references
  static const Color primaryGreen = Color(0xFF93B7BE);    
  static const Color secondaryGreen = Color(0xFF8C9A9E);  
  static const Color backgroundCream = Colors.white;      
  static const Color neutralGrey = Color(0xFF747578);     
  static const Color error = Colors.redAccent;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );
}