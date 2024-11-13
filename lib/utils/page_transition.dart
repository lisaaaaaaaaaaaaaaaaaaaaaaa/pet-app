import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool hasShadow;
  final Border? border;
  final Gradient? gradient;
  final List<Widget>? actions;
  final String? title;
  final Widget? leading;
  final bool isLoading;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.width,
    this.height,
    this.onTap,
    this.hasShadow = true,
    this.border,
    this.gradient,
    this.actions,
    this.title,
    this.leading,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        gradient: gradient,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation ?? 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || leading != null || actions != null) ...[
            Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                if (actions != null) ...[
                  const SizedBox(width: 8),
                  ...actions!,
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Flexible(child: child),
        ],
      ),
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            child: cardContent,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }
}

// Specialized card variants
class InfoCard extends CustomCard {
  InfoCard({
    Key? key,
    required Widget child,
    String? title,
    VoidCallback? onTap,
    List<Widget>? actions,
  }) : super(
          key: key,
          child: child,
          title: title,
          onTap: onTap,
          actions: actions,
          backgroundColor: AppTheme.lightBlue.withOpacity(0.1),
          border: Border.all(color: AppTheme.lightBlue),
          hasShadow: false,
        );
}

class WarningCard extends CustomCard {
  WarningCard({
    Key? key,
    required Widget child,
    String? title,
    VoidCallback? onTap,
    List<Widget>? actions,
  }) : super(
          key: key,
          child: child,
          title: title,
          onTap: onTap,
          actions: actions,
          backgroundColor: AppTheme.warning.withOpacity(0.1),
          border: Border.all(color: AppTheme.warning),
          hasShadow: false,
        );
}

class SuccessCard extends CustomCard {
  SuccessCard({
    Key? key,
    required Widget child,
    String? title,
    VoidCallback? onTap,
    List<Widget>? actions,
  }) : super(
          key: key,
          child: child,
          title: title,
          onTap: onTap,
          actions: actions,
          backgroundColor: AppTheme.success.withOpacity(0.1),
          border: Border.all(color: AppTheme.success),
          hasShadow: false,
        );
}

class ErrorCard extends CustomCard {
  ErrorCard({
    Key? key,
    required Widget child,
    String? title,
    VoidCallback? onTap,
    List<Widget>? actions,
  }) : super(
          key: key,
          child: child,
          title: title,
          onTap: onTap,
          actions: actions,
          backgroundColor: AppTheme.error.withOpacity(0.1),
          border: Border.all(color: AppTheme.error),
          hasShadow: false,
        );
}