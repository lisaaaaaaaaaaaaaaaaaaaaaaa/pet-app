import 'package:flutter/material.dart';
import 'app_theme.dart';

class AuthStyles {
  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimaryColor,
    letterSpacing: 0.5,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: AppTheme.textSecondaryColor,
    letterSpacing: 0.2,
  );

  static const TextStyle linkStyle = TextStyle(
    fontSize: 14,
    color: AppTheme.primaryColor,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String hintText,
    required String labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppTheme.textSecondaryColor)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.surfaceColor,
      labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
      hintStyle: const TextStyle(color: AppTheme.textTertiaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  static final ButtonStyle socialButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppTheme.textPrimaryColor,
    backgroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    side: const BorderSide(color: AppTheme.textTertiaryColor, width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  // Container Decorations
  static final BoxDecoration authCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const BoxDecoration dividerDecoration = BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: AppTheme.textTertiaryColor,
        width: 0.5,
      ),
    ),
  );

  // Spacing
  static const double verticalSpacing = 24.0;
  static const double horizontalSpacing = 24.0;
  static const double formFieldSpacing = 20.0;

  // Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(24.0);

  // Error Styles
  static const TextStyle errorTextStyle = TextStyle(
    color: AppTheme.errorColor,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Loading Indicator
  static const double loadingIndicatorSize = 24.0;
  static const Color loadingIndicatorColor = AppTheme.primaryColor;

  // Social Button Styles
  static const double socialIconSize = 24.0;
  static const EdgeInsets socialIconPadding = EdgeInsets.only(right: 12.0);

  // Animation Durations
  static const Duration fadeInDuration = Duration(milliseconds: 300);
  static const Duration slideUpDuration = Duration(milliseconds: 400);

  // Helper Methods
  static Widget buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppTheme.textTertiaryColor,
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppTheme.textTertiaryColor,
            thickness: 0.5,
          ),
        ),
      ],
    );
  }

  static Widget buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSuccessMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.successColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.successColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
