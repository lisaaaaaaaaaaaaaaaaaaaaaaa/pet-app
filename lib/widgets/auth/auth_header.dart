import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/auth_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final double imageSize;
  final double spacing;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AuthHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.imageSize = 120.0,
    this.spacing = 24.0,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton) ...[
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppTheme.textPrimaryColor,
            ),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          ),
          SizedBox(height: spacing / 2),
        ],

        if (imagePath != null) ...[
          Center(
            child: Image.asset(
              imagePath!,
              height: imageSize,
              width: imageSize,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: spacing),
        ],

        Text(
          title,
          style: AuthStyles.titleStyle,
        ),
        const SizedBox(height: 8),
        
        Text(
          subtitle,
          style: AuthStyles.subtitleStyle,
        ),
        SizedBox(height: spacing),
      ],
    );
  }
}

// Variant for Welcome Screen
class WelcomeHeader extends StatelessWidget {
  final String? imagePath;
  final double imageSize;
  final String welcomeText;
  final String appName;
  final String description;

  const WelcomeHeader({
    Key? key,
    this.imagePath,
    this.imageSize = 160.0,
    this.welcomeText = 'Welcome to',
    this.appName = 'PawTracker',
    this.description = 'Your complete pet care companion',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagePath != null) ...[
          Image.asset(
            imagePath!,
            height: imageSize,
            width: imageSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
        ],

        Text(
          welcomeText,
          style: const TextStyle(
            fontSize: 24,
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          appName,
          style: const TextStyle(
            fontSize: 32,
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// Variant for Success Screen
class AuthSuccessHeader extends StatelessWidget {
  final String title;
  final String message;
  final String? imagePath;
  final double imageSize;
  final VoidCallback? onContinue;

  const AuthSuccessHeader({
    Key? key,
    required this.title,
    required this.message,
    this.imagePath,
    this.imageSize = 120.0,
    this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagePath != null) ...[
          Image.asset(
            imagePath!,
            height: imageSize,
            width: imageSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
        ],

        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            color: AppTheme.successColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ),

        if (onContinue != null) ...[
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}