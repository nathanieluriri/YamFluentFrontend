import 'package:flutter/material.dart';

class SquigglyUnderlineText extends StatelessWidget {
  final String text;
  final Color underlineColor;
  final TextStyle? textStyle;

  const SquigglyUnderlineText({
    super.key,
    required this.text,
    required this.underlineColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? Theme.of(context).textTheme.bodyMedium;
    final textSpan = TextSpan(text: text, style: style);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = _SquigglyTextPainter(
          text: textSpan,
          underlineColor: underlineColor,
          maxWidth: constraints.maxWidth,
        );
        return CustomPaint(
          size: painter.measure(),
          painter: painter,
        );
      },
    );
  }
}

class _SquigglyTextPainter extends CustomPainter {
  final TextSpan text;
  final Color underlineColor;
  final double maxWidth;

  _SquigglyTextPainter({
    required this.text,
    required this.underlineColor,
    required this.maxWidth,
  });

  Size measure() {
    final textPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);
    textPainter.paint(canvas, Offset.zero);

    final paint = Paint()
      ..color = underlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final startY = size.height - 2;
    final path = Path();
    const waveLength = 8.0;
    const waveHeight = 2.5;
    var x = 0.0;
    path.moveTo(0, startY);
    while (x < size.width) {
      path.quadraticBezierTo(
        x + waveLength / 2,
        startY - waveHeight,
        x + waveLength,
        startY,
      );
      x += waveLength;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SquigglyTextPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.underlineColor != underlineColor;
  }
}
