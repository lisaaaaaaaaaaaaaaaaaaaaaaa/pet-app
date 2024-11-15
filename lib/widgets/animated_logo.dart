import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedLogo extends StatefulWidget {
  final double size;
  final bool animate;
  final Duration duration;
  final VoidCallback? onAnimationComplete;
  final bool repeat;
  final Curve curve;

  const AnimatedLogo({
    Key? key,
    this.size = 100,
    this.animate = true,
    this.duration = const Duration(milliseconds: 1500),
    this.onAnimationComplete,
    this.repeat = false,
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: widget.curve),
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159, // 360 degrees in radians
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.8, curve: widget.curve),
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: widget.curve),
      ),
    );

    if (widget.animate) {
      if (widget.repeat) {
        _controller.repeat();
      } else {
        _controller.forward().then((_) {
          widget.onAnimationComplete?.call();
        });
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        if (widget.repeat) {
          _controller.repeat();
        } else {
          _controller.forward();
        }
      } else {
        _controller.stop();
      }
    }
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
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: LogoPainter(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    final outerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius * 0.9, outerPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.7, innerPaint);

    // Heart shape
    final heartPath = Path();
    final heartSize = radius * 0.5;
    final heartCenter = center;

    heartPath.moveTo(heartCenter.dx, heartCenter.dy + heartSize * 0.3);
    heartPath.cubicTo(
      heartCenter.dx - heartSize,
      heartCenter.dy - heartSize * 0.6,
      heartCenter.dx - heartSize,
      heartCenter.dy - heartSize * 1.4,
      heartCenter.dx,
      heartCenter.dy - heartSize * 0.5,
    );
    heartPath.cubicTo(
      heartCenter.dx + heartSize,
      heartCenter.dy - heartSize * 1.4,
      heartCenter.dx + heartSize,
      heartCenter.dy - heartSize * 0.6,
      heartCenter.dx,
      heartCenter.dy + heartSize * 0.3,
    );

    final heartPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}