import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: AppTheme.textSecondaryColor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            }
            Navigator.of(context).pop();
          },
          child: Text(
            cancelLabel,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }
}
