import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool loading;
  final bool outlined;
  final bool disabled;
  final EdgeInsets? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final ButtonStyle? style;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.borderRadius = 8,
    this.icon,
    this.loading = false,
    this.outlined = false,
    this.disabled = false,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? AppTheme.primaryColor;
    final effectiveTextColor =
        textColor ?? (outlined ? effectiveBackgroundColor : Colors.white);

    Widget buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null && !loading) ...[
          Icon(icon, color: effectiveTextColor),
          const SizedBox(width: 8),
        ],
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          )
        else
          Text(
            text,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: fontSize ?? 16,
              fontWeight: fontWeight ?? FontWeight.w600,
            ),
          ),
      ],
    );

    if (width != null) {
      buttonChild = SizedBox(width: width, child: buttonChild);
    }

    final effectiveStyle = style ??
        (outlined ? _outlinedButtonStyle() : _elevatedButtonStyle());

    if (outlined) {
      return OutlinedButton(
        onPressed: (disabled || loading) ? null : onPressed,
        style: effectiveStyle,
        child: buttonChild,
      );
    }

    return ElevatedButton(
      onPressed: (disabled || loading) ? null : onPressed,
      style: effectiveStyle,
      child: buttonChild,
    );
  }

  ButtonStyle _elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      foregroundColor: textColor ?? Colors.white,
      disabledBackgroundColor:
          (backgroundColor ?? AppTheme.primaryColor).withOpacity(0.6),
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: Size(width ?? 0, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    final effectiveColor = backgroundColor ?? AppTheme.primaryColor;
    return OutlinedButton.styleFrom(
      foregroundColor: effectiveColor,
      side: BorderSide(color: effectiveColor),
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: Size(width ?? 0, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final bool loading;
  final bool disabled;
  final String? tooltip;
  final EdgeInsets? padding;

  const CustomIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.loading = false,
    this.disabled = false,
    this.tooltip,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;

    Widget buttonChild = loading
        ? SizedBox(
            width: size * 0.8,
            height: size * 0.8,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          )
        : Icon(
            icon,
            color: effectiveColor,
            size: size,
          );

    if (tooltip != null) {
      buttonChild = Tooltip(
        message: tooltip!,
        child: buttonChild,
      );
    }

    return IconButton(
      onPressed: (disabled || loading) ? null : onPressed,
      padding: padding ?? const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      splashRadius: size * 0.8,
      icon: buttonChild,
    );
  }
}