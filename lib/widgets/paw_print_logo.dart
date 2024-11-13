import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PawPrintLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool useGradient;
  final bool animate;
  final bool showShadow;
  final VoidCallback? onTap;
  final String? label;
  final bool isLoading;

  const PawPrintLogo({
    Key? key,
    this.size = 100,
    this.color,
    this.useGradient = true,
    this.animate = false,
    this.showShadow = true,
    this.onTap,
    this.label,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget logo = _buildLogo(context);

    if (animate) {
      logo = _AnimatedPawPrint(
        child: logo,
      );
    }

    if (isLoading) {
      logo = Stack(
        alignment: Alignment.center,
        children: [
          logo,
          SizedBox(
            width: size * 0.8,
            height: size * 0.8,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.primaryGreen,
              ),
              strokeWidth: 2,
            ),
          ),
        ],
      );
    }

    if (label != null) {
      logo = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(height: 8),
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color ?? AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: logo,
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: useGradient ? AppTheme.primaryGradient : null,
        color: useGradient ? null : (color ?? AppTheme.primaryGreen),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: (color ?? AppTheme.primaryGreen).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _PawPrintPainter(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AnimatedPawPrint extends StatefulWidget {
  final Widget child;

  const _AnimatedPawPrint({
    required this.child,
  });

  @override
  State<_AnimatedPawPrint> createState() => _AnimatedPawPrintState();
}

class _AnimatedPawPrintState extends State<_AnimatedPawPrint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.05),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: 0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
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
            angle: _rotateAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _PawPrintPainter extends CustomPainter {
  final Color color;

  _PawPrintPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final mainPadSize = size.width * 0.4;
    final toeSize = mainPadSize * 0.35;
    final spacing = mainPadSize * 0.4;

    // Main pad
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: mainPadSize,
        height: mainPadSize * 1.2,
      ),
      paint,
    );

    // Toe pads
    canvas.drawCircle(
      Offset(center.dx - spacing, center.dy - spacing),
      toeSize,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + spacing, center.dy - spacing),
      toeSize,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx - spacing * 0.7, center.dy - spacing * 2),
      toeSize,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + spacing * 0.7, center.dy - spacing * 2),
      toeSize,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}