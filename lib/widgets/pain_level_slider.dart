import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PainLevelSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final bool showLabels;
  final bool showEmojis;
  final bool showColors;
  final bool enabled;
  final String? title;
  final String? subtitle;

  const PainLevelSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.showLabels = true,
    this.showEmojis = true,
    this.showColors = true,
    this.enabled = true,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  State<PainLevelSlider> createState() => _PainLevelSliderState();
}

class _PainLevelSliderState extends State<PainLevelSlider> {
  static const _minValue = 0.0;
  static const _maxValue = 10.0;

  Color get _activeColor {
    if (widget.value <= 3) return AppTheme.success;
    if (widget.value <= 6) return AppTheme.warning;
    return AppTheme.error;
  }

  String get _painDescription {
    if (widget.value <= 1) return 'No Pain';
    if (widget.value <= 3) return 'Mild Pain';
    if (widget.value <= 6) return 'Moderate Pain';
    if (widget.value <= 8) return 'Severe Pain';
    return 'Extreme Pain';
  }

  String get _emoji {
    if (widget.value <= 1) return '😊';
    if (widget.value <= 3) return '🙂';
    if (widget.value <= 6) return '😐';
    if (widget.value <= 8) return '😣';
    return '😫';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
        ],
        if (widget.subtitle != null) ...[
          Text(
            widget.subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.neutralGrey,
                ),
          ),
          const SizedBox(height: 16),
        ],
        if (widget.showEmojis)
          Center(
            child: Text(
              _emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _painDescription,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _activeColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: widget.showColors ? _activeColor : AppTheme.primaryGreen,
            inactiveTrackColor: (widget.showColors ? _activeColor : AppTheme.primaryGreen).withOpacity(0.2),
            thumbColor: widget.showColors ? _activeColor : AppTheme.primaryGreen,
            overlayColor: (widget.showColors ? _activeColor : AppTheme.primaryGreen).withOpacity(0.1),
            trackHeight: 8,
            thumbShape: const _CustomSliderThumbShape(),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: _activeColor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: widget.value,
            min: _minValue,
            max: _maxValue,
            divisions: 10,
            label: widget.value.toInt().toString(),
            onChanged: widget.enabled ? widget.onChanged : null,
          ),
        ),
        if (widget.showLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No Pain',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGrey,
                      ),
                ),
                Text(
                  'Extreme Pain',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGrey,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CustomSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final double disabledThumbRadius;

  const _CustomSliderThumbShape({
    this.enabledThumbRadius = 12,
    this.disabledThumbRadius = 8,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? enabledThumbRadius : disabledThumbRadius);
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

    final paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      center,
      enabledThumbRadius,
      paint,
    );

    canvas.drawCircle(
      center,
      enabledThumbRadius,
      borderPaint,
    );
  }
}

// Helper class for predefined pain levels
class PainLevel {
  static const none = 0.0;
  static const mild = 2.0;
  static const moderate = 5.0;
  static const severe = 7.0;
  static const extreme = 10.0;
}