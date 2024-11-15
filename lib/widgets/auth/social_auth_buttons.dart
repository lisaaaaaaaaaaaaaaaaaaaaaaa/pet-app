import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'auth_button.dart';

class SocialAuthButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onTwitterPressed;
  final bool showDivider;
  final String dividerText;
  final double spacing;
  final bool showAllButtons;

  const SocialAuthButtons({
    Key? key,
    this.isLoading = false,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
    this.onTwitterPressed,
    this.showDivider = true,
    this.dividerText = 'Or continue with',
    this.spacing = 12.0,
    this.showAllButtons = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) ...[
          _buildDivider(),
          SizedBox(height: spacing * 2),
        ],

        if (showAllButtons)
          _buildButtonGrid(context)
        else
          _buildButtonList(),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppTheme.borderColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            dividerText,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppTheme.borderColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonGrid(BuildContext context) {
    final buttons = _getEnabledButtons();
    
    // If only one button, show it full width
    if (buttons.length == 1) {
      return buttons.first;
    }

    // If two buttons, show them in a row
    if (buttons.length == 2) {
      return Row(
        children: [
          Expanded(child: buttons[0]),
          SizedBox(width: spacing),
          Expanded(child: buttons[1]),
        ],
      );
    }

    // For more buttons, create a grid
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: 3,
      children: buttons,
    );
  }

  Widget _buildButtonList() {
    final buttons = _getEnabledButtons();
    return Column(
      children: buttons.map((button) {
        final index = buttons.indexOf(button);
        return Column(
          children: [
            button,
            if (index < buttons.length - 1) 
              SizedBox(height: spacing),
          ],
        );
      }).toList(),
    );
  }

  List<Widget> _getEnabledButtons() {
    final buttons = <Widget>[];

    if (onGooglePressed != null) {
      buttons.add(
        _SocialAuthButton(
          text: 'Google',
          icon: 'assets/icons/google.png',
          onPressed: isLoading ? null : onGooglePressed,
          isLoading: isLoading,
        ),
      );
    }

    if (onFacebookPressed != null) {
      buttons.add(
        _SocialAuthButton(
          text: 'Facebook',
          icon: 'assets/icons/facebook.png',
          onPressed: isLoading ? null : onFacebookPressed,
          isLoading: isLoading,
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
        ),
      );
    }

    if (onApplePressed != null) {
      buttons.add(
        _SocialAuthButton(
          text: 'Apple',
          icon: 'assets/icons/apple.png',
          onPressed: isLoading ? null : onApplePressed,
          isLoading: isLoading,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        ),
      );
    }

    if (onTwitterPressed != null) {
      buttons.add(
        _SocialAuthButton(
          text: 'Twitter',
          icon: 'assets/icons/twitter.png',
          onPressed: isLoading ? null : onTwitterPressed,
          isLoading: isLoading,
          backgroundColor: const Color(0xFF1DA1F2),
          textColor: Colors.white,
        ),
      );
    }

    return buttons;
  }
}

class _SocialAuthButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const _SocialAuthButton({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor: textColor ?? Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.black,
                  ),
                ),
              ],
            ),
    );
  }
}

// Optional: Compact Social Auth Buttons
class CompactSocialAuthButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onApplePressed;
  final double spacing;

  const CompactSocialAuthButtons({
    Key? key,
    this.isLoading = false,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
    this.spacing = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onGooglePressed != null)
          _CompactSocialButton(
            icon: 'assets/icons/google.png',
            onPressed: isLoading ? null : onGooglePressed,
            isLoading: isLoading,
          ),
        if (onFacebookPressed != null) ...[
          SizedBox(width: spacing),
          _CompactSocialButton(
            icon: 'assets/icons/facebook.png',
            onPressed: isLoading ? null : onFacebookPressed,
            isLoading: isLoading,
            backgroundColor: const Color(0xFF1877F2),
          ),
        ],
        if (onApplePressed != null) ...[
          SizedBox(width: spacing),
          _CompactSocialButton(
            icon: 'assets/icons/apple.png',
            onPressed: isLoading ? null : onApplePressed,
            isLoading: isLoading,
            backgroundColor: Colors.black,
          ),
        ],
      ],
    );
  }
}

class _CompactSocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;

  const _CompactSocialButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Image.asset(
                icon,
                height: 24,
                width: 24,
              ),
        color: Colors.white,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}