import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final Widget? icon;
  final Color? confirmButtonColor;
  final bool showCancelButton;
  final bool barrierDismissible;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
    this.confirmButtonColor,
    this.showCancelButton = true,
    this.barrierDismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: icon,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimaryColor,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: AppTheme.textSecondaryColor,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        if (showCancelButton)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              if (onCancel != null) onCancel!();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            if (onConfirm != null) onConfirm!();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor ??
                (isDestructive ? AppTheme.errorColor : AppTheme.primaryColor),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            confirmText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.all(16),
      actionsAlignment: MainAxisAlignment.center,
    );
  }

  // Static method to show the dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? icon,
    Color? confirmButtonColor,
    bool showCancelButton = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
        icon: icon,
        confirmButtonColor: confirmButtonColor,
        showCancelButton: showCancelButton,
        barrierDismissible: barrierDismissible,
      ),
    );
  }
}

// Predefined variants
class DeleteConfirmDialog extends StatelessWidget {
  final String itemType;
  final String? itemName;
  final VoidCallback? onConfirm;

  const DeleteConfirmDialog({
    Key? key,
    required this.itemType,
    this.itemName,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Delete ${itemName ?? itemType}?',
      message: 'This action cannot be undone. Are you sure you want to delete this ${itemName ?? itemType}?',
      confirmText: 'Delete',
      isDestructive: true,
      icon: const Icon(
        Icons.delete_outline,
        color: AppTheme.errorColor,
        size: 48,
      ),
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String itemType,
    String? itemName,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        itemType: itemType,
        itemName: itemName,
        onConfirm: onConfirm,
      ),
    );
  }
}

class LogoutConfirmDialog extends StatelessWidget {
  final VoidCallback? onConfirm;

  const LogoutConfirmDialog({
    Key? key,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout from your account?',
      confirmText: 'Logout',
      confirmButtonColor: AppTheme.warningColor,
      icon: const Icon(
        Icons.logout_rounded,
        color: AppTheme.warningColor,
        size: 48,
      ),
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => LogoutConfirmDialog(onConfirm: onConfirm),
    );
  }
}

class DiscardChangesDialog extends StatelessWidget {
  final VoidCallback? onConfirm;

  const DiscardChangesDialog({
    Key? key,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Are you sure you want to discard them?',
      confirmText: 'Discard',
      isDestructive: true,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppTheme.warningColor,
        size: 48,
      ),
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DiscardChangesDialog(onConfirm: onConfirm),
    );
  }
}