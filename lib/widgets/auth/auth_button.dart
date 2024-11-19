import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: backgroundColor ?? AppTheme.primaryColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: padding,
              ),
              child: _buildButtonContent(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppTheme.primaryColor,
                foregroundColor: textColor ?? Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: padding,
                elevation: 0,
              ),
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Social Auth Buttons
class GoogleAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleAuthButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthButton(
      text: 'Continue with Google',
      onPressed: onPressed,
      isLoading: isLoading,
      isOutlined: true,
      icon: Icons.g_mobiledata,
      backgroundColor: Colors.white,
      textColor: AppTheme.textPrimaryColor,
    );
  }
}

class FacebookAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const FacebookAuthButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthButton(
      text: 'Continue with Facebook',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: const Color(0xFF1877F2),
      icon: Icons.facebook,
    );
  }
}

class AppleAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AppleAuthButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthButton(
      text: 'Continue with Apple',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.black,
      icon: Icons.apple,
    );
  }
}

class TwitterAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const TwitterAuthButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthButton(
      text: 'Continue with Twitter',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: const Color(0xFF1DA1F2),
      icon: Icons.flutter_dash,
    );
  }
}