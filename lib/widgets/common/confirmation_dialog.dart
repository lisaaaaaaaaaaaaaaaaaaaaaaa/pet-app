import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;  // Keep as 'content' since that's what profile_screen.dart uses
  final String confirmText;
  final String cancelText;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,  // Match the parameter name used in profile_screen.dart
    required this.confirmText,
    required this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          color: AppTheme.textDark,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}