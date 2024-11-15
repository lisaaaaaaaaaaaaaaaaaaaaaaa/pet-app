import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showText;
  final bool showTagline;
  final TextStyle? textStyle;
  final TextStyle? taglineStyle;
  final double? iconSize;
  final MainAxisAlignment alignment;
  final bool vertical;

  const AppLogo({
    Key? key,
    this.size = 40,
    this.color,
    this.showText = true,
    this.showTagline = false,
    this.textStyle,
    this.taglineStyle,
    this.iconSize,
    this.alignment = MainAxisAlignment.center,
    this.vertical = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppTheme.primaryColor;
    final effectiveIconSize = iconSize ?? size;

    Widget logoIcon = SizedBox(
      width: effectiveIconSize,
      height: effectiveIconSize,
      child: CustomPaint(
        painter: LogoPainter(color: logoColor),
      ),
    );

    Widget? logoText;
    if (showText) {
      logoText = Text(
        'HealthTracker',
        style: textStyle ??
            TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: logoColor,
              letterSpacing: 0.5,
            ),
      );
    }

    Widget? tagline;
    if (showTagline) {
      tagline = Text(
        'Your Health, Your Way',
        style: taglineStyle ??
            TextStyle(
              fontSize: size * 0.3,
              color: logoColor.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
      );
    }

    if (vertical) {
      return Column(
        mainAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          logoIcon,
          if (showText) ...[
            SizedBox(height: size * 0.2),
            logoText!,
          ],
          if (showTagline) ...[
            SizedBox(height: size * 0.1),
            tagline!,
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
        if (showText) ...[
          SizedBox(width: size * 0.3),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              logoText!,
              if (showTagline) ...[
                SizedBox(height: size * 0.1),
                tagline!,
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  final Color color;

  LogoPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;
    canvas.drawCircle(center, radius * 0.9, outerPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = color.withOpacity(0.2)
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
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}