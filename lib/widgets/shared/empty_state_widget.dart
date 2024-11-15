import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customIcon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final EdgeInsets padding;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.customIcon,
    this.iconSize = 80,
    this.iconColor,
    this.titleStyle,
    this.messageStyle,
    this.padding = const EdgeInsets.all(24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIcon != null)
              customIcon!
            else if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppTheme.textSecondaryColor.withOpacity(0.5),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: titleStyle ??
                  const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: messageStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Factory constructors for common empty states
  factory EmptyStateWidget.noData({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      title: title ?? 'No Data Available',
      message: message ?? 'There is no data to display at the moment.',
      icon: Icons.inbox_outlined,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.noResults({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      title: title ?? 'No Results Found',
      message: message ?? 'Try adjusting your search or filters.',
      icon: Icons.search_off_outlined,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.error({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      title: title ?? 'Something Went Wrong',
      message: message ?? 'An error occurred while loading the data.',
      icon: Icons.error_outline,
      buttonText: buttonText ?? 'Try Again',
      onButtonPressed: onButtonPressed,
      iconColor: AppTheme.errorColor,
    );
  }

  factory EmptyStateWidget.noConnection({
    String? title,
    String? message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      title: title ?? 'No Internet Connection',
      message: message ?? 'Please check your internet connection and try again.',
      icon: Icons.wifi_off_outlined,
      buttonText: buttonText ?? 'Retry',
      onButtonPressed: onButtonPressed,
    );
  }

  factory EmptyStateWidget.noItems({
    required String itemType,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyStateWidget(
      title: 'No $itemType Yet',
      message: 'Tap the button below to add your first $itemType.',
      icon: Icons.add_circle_outline,
      buttonText: buttonText ?? 'Add $itemType',
      onButtonPressed: onButtonPressed,
    );
  }
}