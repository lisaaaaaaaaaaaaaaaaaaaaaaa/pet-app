import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PawPrintBackground extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double opacity;
  final bool animate;
  final int pawCount;
  final double pawSize;
  final bool randomize;
  final bool isReversed;

  const PawPrintBackground({
    Key? key,
    required this.child,
    this.color,
    this.opacity = 0.05,
    this.animate = false,
    this.pawCount = 20,
    this.pawSize = 24,
    this.randomize = true,
    this.isReversed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (animate)
          _AnimatedPawPrints(
            color: color ?? AppTheme.primaryGreen,
            opacity: opacity,
            pawCount: pawCount,
            pawSize: pawSize,
            randomize: randomize,
            isReversed: isReversed,
          )
        else
          _StaticPawPrints(
            color: color ?? AppTheme.primaryGreen,
            opacity: opacity,
            pawCount: pawCount,
            pawSize: pawSize,
            randomize: randomize,
            isReversed: isReversed,
          ),
        child,
      ],
    );
  }
}

class _StaticPawPrints extends StatelessWidget {
  final Color color;
  final double opacity;
  final int pawCount;
  final double pawSize;
  final bool randomize;
  final bool isReversed;

  const _StaticPawPrints({
    required this.color,
    required this.opacity,
    required this.pawCount,
    required this.pawSize,
    required this.randomize,
    required this.isReversed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: PawPrintPainter(
            color: color,
            opacity: opacity,
            pawCount: pawCount,
            pawSize: pawSize,
            randomize: randomize,
            isReversed: isReversed,
          ),
        );
      },
    );
  }
}

class _AnimatedPawPrints extends StatefulWidget {
  final Color color;
  final double opacity;
  final int pawCount;
  final double pawSize;
  final bool randomize;
  final bool isReversed;

  const _AnimatedPawPrints({
    required this.color,
    required this.opacity,
    required this.pawCount,
    required this.pawSize,
    required this.randomize,
    required this.isReversed,
  });

  @override
  State<_AnimatedPawPrints> createState() => _AnimatedPawPrintsState();
}

class _AnimatedPawPrintsState extends State<_AnimatedPawPrints>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: PawPrintPainter(
                color: widget.color,
                opacity: widget.opacity,
                pawCount: widget.pawCount,
                pawSize: widget.pawSize,
                randomize: widget.randomize,
                isReversed: widget.isReversed,
                animation: _controller.value,
              ),
            );
          },
        );
      },
    );
  }
}

class PawPrintPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final int pawCount;
  final double pawSize;
  final bool randomize;
  final bool isReversed;
  final double? animation;
  final Random _random = Random();

  PawPrintPainter({
    required this.color,
    required this.opacity,
    required this.pawCount,
    required this.pawSize,
    required this.randomize,
    required this.isReversed,
    this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < pawCount; i++) {
      double x, y;
      if (randomize) {
        x = _random.nextDouble() * size.width;
        y = _random.nextDouble() * size.height;
      } else {
        x = (i % 5) * (size.width / 4);
        y = (i ~/ 5) * (size.height / 4);
      }

      if (animation != null) {
        y += size.height * animation! * (isReversed ? -1 : 1);
        y = y % size.height;
      }

      _drawPawPrint(canvas, paint, x, y);
    }
  }

  void _drawPawPrint(Canvas canvas, Paint paint, double x, double y) {
    // Main pad
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: pawSize,
        height: pawSize * 1.2,
      ),
      paint,
    );

    // Toe pads
    final double toeSize = pawSize * 0.4;
    final double spacing = pawSize * 0.3;

    // Left toes
    canvas.drawCircle(
      Offset(x - spacing, y - spacing),
      toeSize,
      paint,
    );
    canvas.drawCircle(
      Offset(x + spacing, y - spacing),
      toeSize,
      paint,
    );

    // Right toes
    canvas.drawCircle(
      Offset(x - spacing * 0.7, y - spacing * 2),
      toeSize,
      paint,
    );
    canvas.drawCircle(
      Offset(x + spacing * 0.7, y - spacing * 2),
      toeSize,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant PawPrintPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity;
  }
}