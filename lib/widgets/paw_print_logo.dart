import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PawPrintLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool animate;
  final Duration animationDuration;
  final bool showShadow;
  final bool filled;
  final double strokeWidth;
  final VoidCallback? onTap;

  const PawPrintLogo({
    Key? key,
    this.size = 100,
    this.color,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.showShadow = true,
    this.filled = true,
    this.strokeWidth = 2.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;

    Widget logo = CustomPaint(
      size: Size(size, size),
      painter: _PawPrintPainter(
        color: effectiveColor,
        filled: filled,
        strokeWidth: strokeWidth,
      ),
    );

    if (showShadow) {
      logo = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: effectiveColor.withOpacity(0.2),
              blurRadius: size * 0.1,
              spreadRadius: size * 0.02,
            ),
          ],
        ),
        child: logo,
      );
    }

    if (animate) {
      logo = _AnimatedPawPrint(
        duration: animationDuration,
        child: logo,
      );
    }

    if (onTap != null) {
      logo = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: logo,
      );
    }

    return logo;
  }
}

class _AnimatedPawPrint extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _AnimatedPawPrint({
    Key? key,
    required this.child,
    required this.duration,
  }) : super(key: key);

  @override
  State<_AnimatedPawPrint> createState() => _AnimatedPawPrintState();
}

class _AnimatedPawPrintState extends State<_AnimatedPawPrint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 60.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
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
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Transform.rotate(
          angle: _rotateAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _PawPrintPainter extends CustomPainter {
  final Color color;
  final bool filled;
  final double strokeWidth;

  _PawPrintPainter({
    required this.color,
    required this.filled,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final mainPadSize = size.width * 0.4;
    final toePadSize = size.width * 0.2;

    // Main pad
    final mainPadPath = Path()
      ..addOval(Rect.fromCenter(
        center: center + const Offset(0, 10),
        width: mainPadSize * 1.2,
        height: mainPadSize,
      ));

    // Toe pads
    final toePadOffsets = [
      Offset(-toePadSize * 0.8, -toePadSize * 0.8),
      Offset(toePadSize * 0.8, -toePadSize * 0.8),
      Offset(-toePadSize, 0),
      Offset(toePadSize, 0),
    ];

    final toePaths = toePadOffsets.map((offset) {
      return Path()
        ..addOval(Rect.fromCenter(
          center: center + offset,
          width: toePadSize,
          height: toePadSize * 0.9,
        ));
    }).toList();

    // Draw all paths
    canvas.drawPath(mainPadPath, paint);
    for (final path in toePaths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}