import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final bool isOutlined;
  final bool isText;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final bool expandWidth;
  final bool mini;

  const CustomButton({
    Key? key,
    this.text,
    this.child,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.isOutlined = false,
    this.isText = false,
    this.icon,
    this.width,
    this.height = 48,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.padding,
    this.expandWidth = true,
    this.mini = false,
  })  : assert(text != null || child != null, 'Either text or child must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = style ??
        _getButtonStyle(
          context,
          backgroundColor: backgroundColor,
          textColor: textColor,
          elevation: elevation,
        );

    Widget buttonChild = _buildButtonChild(context);

    if (isLoading) {
      buttonChild = _LoadingChild(
        child: buttonChild,
        textColor: textColor ?? _getTextColor(context),
      );
    }

    if (icon != null) {
      buttonChild = _IconChild(
        icon: icon!,
        child: buttonChild,
        mini: mini,
      );
    }

    Widget button;
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    } else if (isText) {
      button = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    }

    if (!expandWidth) {
      return button;
    }

    return SizedBox(
      width: width ?? (mini ? null : double.infinity),
      height: height,
      child: button,
    );
  }

  Widget _buildButtonChild(BuildContext context) {
    if (child != null) return child!;

    return Text(
      text!,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor ?? _getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
    );
  }

  ButtonStyle _getButtonStyle(
    BuildContext context, {
    Color? backgroundColor,
    Color? textColor,
    double? elevation,
  }) {
    final theme = Theme.of(context);

    if (isOutlined) {
      return OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryGreen,
        side: BorderSide(color: AppTheme.primaryGreen),
        padding: padding ?? EdgeInsets.symmetric(horizontal: mini ? 12 : 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    if (isText) {
      return TextButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryGreen,
        padding: padding ?? EdgeInsets.symmetric(horizontal: mini ? 8 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppTheme.primaryGreen,
      foregroundColor: textColor ?? Colors.white,
      elevation: elevation ?? 2,
      padding: padding ?? EdgeInsets.symmetric(horizontal: mini ? 16 : 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Color _getTextColor(BuildContext context) {
    if (isOutlined || isText) {
      return AppTheme.primaryGreen;
    }
    return Colors.white;
  }
}

class _LoadingChild extends StatelessWidget {
  final Widget child;
  final Color textColor;

  const _LoadingChild({
    required this.child,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0,
          child: child,
        ),
        SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
            strokeWidth: 2,
          ),
        ),
      ],
    );
  }
}

class _IconChild extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final bool mini;

  const _IconChild({
    required this.icon,
    required this.child,
    required this.mini,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: mini ? 18 : 24),
        SizedBox(width: mini ? 4 : 8),
        child,
      ],
    );
  }
}

// Specialized button variants
class PrimaryButton extends CustomButton {
  PrimaryButton({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool expandWidth = true,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          expandWidth: expandWidth,
        );
}

class SecondaryButton extends CustomButton {
  SecondaryButton({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool expandWidth = true,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          isOutlined: true,
          expandWidth: expandWidth,
        );
}

class TextActionButton extends CustomButton {
  TextActionButton({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          isText: true,
          expandWidth: false,
          mini: true,
        );
}