import 'package:flutter/material.dart';
import 'app_theme.dart';

class AuthStyles {
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 16.0;
  static const double spacing = 16.0;

  static TextStyle titleStyle = const TextStyle(
    color: AppTheme.textDark,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );

  static TextStyle subtitleStyle = const TextStyle(
    color: AppTheme.secondaryGreen,
    fontSize: 16.0,
  );

  static InputDecoration inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, color: AppTheme.secondaryGreen),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: AppTheme.secondaryGreen),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.error, width: 2),
      ),
      errorStyle: TextStyle(color: AppTheme.error),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppTheme.primaryGreen,
    padding: const EdgeInsets.symmetric(vertical: 16),
    side: BorderSide(color: AppTheme.primaryGreen),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppTheme.primaryGreen,
    padding: const EdgeInsets.symmetric(vertical: 8),
  );
}
