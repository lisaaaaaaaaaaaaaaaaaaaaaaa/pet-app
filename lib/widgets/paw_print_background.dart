import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class PawPrintBackground extends StatelessWidget {
  final Color? color;
  final int pawCount;
  final double minSize;
  final double maxSize;
  final double opacity;
  final bool randomRotation;
  final bool animate;
  final Duration animationDuration;

  const PawPrintBackground({
    Key? key,
    this.color,
    this.pawCount = 20,
    this.minSize = 24,
    this.maxSize = 48,
    this.opacity = 0.1,
    this.randomRotation = true,
    this.animate = true,
    this.animationDuration = const Duration(seconds: 20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(
            pawCount,
            (index) => _PawPrint(
              left: _randomPosition(constraints.maxWidth),
              top: _randomPosition(constraints.maxHeight),
              size: _randomSize(),
              color: color ?? AppTheme.primaryColor,
              opacity: opacity,
              rotation: randomRotation ? _randomRotation() : 0,
              animate: animate,
              animationDuration: animationDuration,
            ),
          ),
        );
      },
    );
  }

  double _randomPosition(double max) {
    return math.Random().nextDouble() * max;
  }

  double _randomSize() {
    return minSize + math.Random().nextDouble() * (maxSize - minSize);
  }

  double _randomRotation() {
    return math.Random().nextDouble() * 2 * math.pi;
  }
}

class _PawPrint extends StatefulWidget {
  final double left;
  final double top;
  final double size;
  final Color color;
  final double opacity;
  final double rotation;
  final bool animate;
  final Duration animationDuration;

  const _PawPrint({
    Key? key,
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.opacity,
    required this.rotation,
    required this.animate,
    required this.animationDuration,
  }) : super(key: key);

  @override
  State<_PawPrint> createState() => _PawPrintState();
}

class _PawPrintState extends State<_PawPrint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: widget.opacity,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: Transform.rotate(
        angle: widget.rotation,
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) => CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _PawPrintPainter(
              color: widget.color.withOpacity(_opacityAnimation.value),
            ),
          ),
        ),
      ),
    );
  }
}

class _PawPrintPainter extends CustomPainter {
  final Color color;

  _PawPrintPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final padSize = size.width * 0.3;
    final toeSize = size.width * 0.2;

    // Main pad
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: padSize * 1.5,
        height: padSize,
      ),
      paint,
    );

    // Toe pads
    final toeOffsets = [
      Offset(-toeSize, -toeSize * 1.5), // Top left
      Offset(toeSize, -toeSize * 1.5), // Top right
      Offset(-toeSize * 1.2, -toeSize * 0.5), // Middle left
      Offset(toeSize * 1.2, -toeSize * 0.5), // Middle right
    ];

    for (final offset in toeOffsets) {
      canvas.drawCircle(
        center + offset,
        toeSize / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}