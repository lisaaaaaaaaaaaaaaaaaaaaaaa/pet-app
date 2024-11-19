import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGrey = Color(0xFF717C89);    // Slate grey
  static const Color secondaryBlue = Color(0xFF8AA2A9);  // Muted blue-grey
  static const Color accentGreen = Color(0xFF90BAAD);    // Sage green
  
  static const Color background = Color(0xFFF5F7F9);
  static const Color textDark = Color(0xFF2D3142);
  static const Color textLight = Color(0xFFF5F7F9);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: AppColors.primaryGrey,
    scaffoldBackgroundColor: AppColors.background,
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentGreen,
        foregroundColor: AppColors.textLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textDark,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textDark,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
      ),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGrey,
      foregroundColor: AppColors.textLight,
      elevation: 0,
    ),
  );
}
