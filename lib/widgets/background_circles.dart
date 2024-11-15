import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class BackgroundCircles extends StatelessWidget {
  final int circleCount;
  final List<Color>? colors;
  final bool animate;
  final Duration animationDuration;
  final double minRadius;
  final double maxRadius;
  final double minOpacity;
  final double maxOpacity;
  final bool randomizePositions;
  final bool blendMode;

  const BackgroundCircles({
    Key? key,
    this.circleCount = 5,
    this.colors,
    this.animate = true,
    this.animationDuration = const Duration(seconds: 20),
    this.minRadius = 50,
    this.maxRadius = 200,
    this.minOpacity = 0.1,
    this.maxOpacity = 0.3,
    this.randomizePositions = true,
    this.blendMode = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(
            circleCount,
            (index) => _AnimatedCircle(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: _getColor(index),
              animate: animate,
              animationDuration: animationDuration,
              minRadius: minRadius,
              maxRadius: maxRadius,
              minOpacity: minOpacity,
              maxOpacity: maxOpacity,
              randomizePosition: randomizePositions,
              blendMode: blendMode,
            ),
          ),
        );
      },
    );
  }

  Color _getColor(int index) {
    if (colors != null && colors!.isNotEmpty) {
      return colors![index % colors!.length];
    }
    return AppTheme.primaryColor;
  }
}

class _AnimatedCircle extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final bool animate;
  final Duration animationDuration;
  final double minRadius;
  final double maxRadius;
  final double minOpacity;
  final double maxOpacity;
  final bool randomizePosition;
  final bool blendMode;

  const _AnimatedCircle({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
    required this.animate,
    required this.animationDuration,
    required this.minRadius,
    required this.maxRadius,
    required this.minOpacity,
    required this.maxOpacity,
    required this.randomizePosition,
    required this.blendMode,
  }) : super(key: key);

  @override
  State<_AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<_AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionXAnimation;
  late Animation<double> _positionYAnimation;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _initializeAnimations();

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  void _initializeAnimations() {
    final random = math.Random();

    // Initial positions
    final startX = widget.randomizePosition
        ? random.nextDouble() * widget.width
        : widget.width / 2;
    final startY = widget.randomizePosition
        ? random.nextDouble() * widget.height
        : widget.height / 2;

    // Target positions
    final endX = widget.randomizePosition
        ? random.nextDouble() * widget.width
        : widget.width / 2;
    final endY = widget.randomizePosition
        ? random.nextDouble() * widget.height
        : widget.height / 2;

    _positionXAnimation = Tween<double>(
      begin: startX,
      end: endX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _positionYAnimation = Tween<double>(
      begin: startY,
      end: endY,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _radiusAnimation = Tween<double>(
      begin: widget.minRadius,
      end: widget.maxRadius,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return Positioned(
          left: _positionXAnimation.value - _radiusAnimation.value / 2,
          top: _positionYAnimation.value - _radiusAnimation.value / 2,
          child: Container(
            width: _radiusAnimation.value,
            height: _radiusAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(_opacityAnimation.value),
              backgroundBlendMode: widget.blendMode ? BlendMode.screen : null,
            ),
          ),
        );
      },
    );
  }
}