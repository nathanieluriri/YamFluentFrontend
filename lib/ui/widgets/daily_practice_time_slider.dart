import 'package:flutter/material.dart';

class DailyPracticeTimeSlider extends StatelessWidget {
  final String title;
  final String valueText;
  final String minLabel;
  final String maxLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const DailyPracticeTimeSlider({
    super.key,
    required this.title,
    required this.valueText,
    required this.minLabel,
    required this.maxLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF002331),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: titleStyle,
                ),
              ),
              Text(
                valueText,
                style: valueStyle,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10,
              activeTrackColor: const Color(0xFF2EA9DE),
              inactiveTrackColor: const Color(0xFF454544),
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: _DailyPracticeThumbShape(
                radius: 14,
                borderWidth: 3,
                borderColor: Colors.white,
                fillColor: const Color(0xFFBBEAFF),
              ),
              trackShape: const RoundedRectSliderTrackShape(),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(minLabel, style: labelStyle),
              const Spacer(),
              Text(maxLabel, style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyPracticeThumbShape extends SliderComponentShape {
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final Color fillColor;

  const _DailyPracticeThumbShape({
    required this.radius,
    required this.borderWidth,
    required this.borderColor,
    required this.fillColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius);
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
    final canvas = context.canvas;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);
  }
}
