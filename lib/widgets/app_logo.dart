import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  final bool isAnimated;
  final bool useGradient;

  const AppLogo({
    Key? key,
    this.size = 100,
    this.showText = true,
    this.color,
    this.isAnimated = false,
    this.useGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: useGradient
            ? AppTheme.primaryGradient
            : null,
        color: useGradient ? null : (color ?? AppTheme.primaryGreen),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );

    final Widget logo = isAnimated
        ? TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: logoIcon,
          )
        : logoIcon;

    if (!showText) {
      return logo;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        if (showText) ...[
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  'Golden Years',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color ?? AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Senior Pet Care',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.secondaryGreen,
                        letterSpacing: 0.8,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// Animated variant for splash screen
class AnimatedAppLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final Color? color;
  final VoidCallback? onAnimationComplete;

  const AnimatedAppLogo({
    Key? key,
    this.size = 120,
    this.showText = true,
    this.color,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: AppLogo(
              size: widget.size,
              showText: widget.showText,
              color: widget.color,
              isAnimated: false,
            ),
          ),
        );
      },
    );
  }
}