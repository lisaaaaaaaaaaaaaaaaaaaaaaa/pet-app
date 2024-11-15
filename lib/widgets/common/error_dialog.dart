import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Widget? icon;
  final bool showRetryButton;
  final bool barrierDismissible;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.primaryButtonText = 'OK',
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.icon,
    this.showRetryButton = false,
    this.barrierDismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: icon ??
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 48,
          ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.errorColor,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        if (secondaryButtonText != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onSecondaryButtonPressed != null) {
                onSecondaryButtonPressed!();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              secondaryButtonText!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onPrimaryButtonPressed != null) {
              onPrimaryButtonPressed!();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            primaryButtonText,
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
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String primaryButtonText = 'OK',
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    Widget? icon,
    bool showRetryButton = false,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryButtonPressed: onPrimaryButtonPressed,
        onSecondaryButtonPressed: onSecondaryButtonPressed,
        icon: icon,
        showRetryButton: showRetryButton,
      ),
    );
  }
}

// Predefined error dialog variants
class NetworkErrorDialog extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorDialog({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      primaryButtonText: 'Retry',
      onPrimaryButtonPressed: onRetry,
      icon: const Icon(
        Icons.wifi_off,
        color: AppTheme.errorColor,
        size: 48,
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => NetworkErrorDialog(onRetry: onRetry),
    );
  }
}

class ServerErrorDialog extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? errorCode;

  const ServerErrorDialog({
    Key? key,
    this.onRetry,
    this.errorCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later.' +
          (errorCode != null ? '\nError Code: $errorCode' : ''),
      primaryButtonText: 'Retry',
      secondaryButtonText: 'Cancel',
      onPrimaryButtonPressed: onRetry,
      icon: const Icon(
        Icons.cloud_off,
        color: AppTheme.errorColor,
        size: 48,
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    VoidCallback? onRetry,
    String? errorCode,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ServerErrorDialog(
        onRetry: onRetry,
        errorCode: errorCode,
      ),
    );
  }
}

class ValidationErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirm;

  const ValidationErrorDialog({
    Key? key,
    required this.message,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Invalid Input',
      message: message,
      primaryButtonText: 'OK',
      onPrimaryButtonPressed: onConfirm,
      icon: const Icon(
        Icons.warning_amber,
        color: AppTheme.warningColor,
        size: 48,
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String message,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ValidationErrorDialog(
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }
}