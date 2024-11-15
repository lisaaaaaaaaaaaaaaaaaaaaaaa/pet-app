import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PainLevelSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final bool showLabels;
  final bool showEmojis;
  final bool showColors;
  final double height;
  final EdgeInsets padding;
  final String? title;
  final String? subtitle;

  const PainLevelSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.showLabels = true,
    this.showEmojis = true,
    this.showColors = true,
    this.height = 120,
    this.padding = const EdgeInsets.all(16),
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              if (showLabels)
                const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: _getTrackColor(value),
                    inactiveTrackColor:
                        AppTheme.textSecondaryColor.withOpacity(0.2),
                    thumbColor: _getTrackColor(value),
                    overlayColor: _getTrackColor(value).withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape: _CustomSliderThumbShape(
                      showEmoji: showEmojis,
                      painLevel: value,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 24,
                    ),
                  ),
                  child: Slider(
                    value: value,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: onChanged,
                  ),
                ),
              ),
              if (showLabels)
                const Text(
                  '10',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
            ],
          ),
          if (showLabels) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('No Pain', Colors.green),
                _buildLabel('Moderate', Colors.orange),
                _buildLabel('Severe', Colors.red),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Row(
      children: [
        if (showColors) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Color _getTrackColor(double value) {
    if (value <= 3) {
      return Colors.green;
    } else if (value <= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class _CustomSliderThumbShape extends SliderComponentShape {
  final bool showEmoji;
  final double painLevel;

  const _CustomSliderThumbShape({
    required this.showEmoji,
    required this.painLevel,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw thumb circle
    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 9, borderPaint);

    if (showEmoji) {
      final emoji = _getEmoji(painLevel);
      final textPainter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: const TextStyle(
            fontSize: 12,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  String _getEmoji(double value) {
    if (value <= 2) return '😊';
    if (value <= 4) return '🙂';
    if (value <= 6) return '😐';
    if (value <= 8) return '😣';
    return '😫';
  }
}