import 'package:flutter/material.dart';

/// Utility: hex color like 0xFF2EA9DE
class HexColor extends Color {
  HexColor(super.hex);
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Inner shadow overlay using a CustomPainter.
/// Note: Flutter doesn't have a native inner-shadow; this painter is a common workaround.
class InnerShadow extends StatelessWidget {
  const InnerShadow({
    super.key,
    required this.child,
    required this.color,
    required this.blur,
    required this.offset,
    this.borderRadius = BorderRadius.zero,
  });

  final Widget child;
  final Color color;
  final double blur;
  final Offset offset;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _InnerShadowPainter(
                color: color,
                blur: blur,
                offset: offset,
                borderRadius: borderRadius,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  _InnerShadowPainter({
    required this.color,
    required this.blur,
    required this.offset,
    required this.borderRadius,
  });

  final Color color;
  final double blur;
  final Offset offset;
  final BorderRadius borderRadius;

  double _sigma(double radius) => radius * 0.57735 + 0.5; // decent blur->sigma

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = (color.a * 255.0).round() & 0xff;
    if (alpha == 0) return;

    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    canvas.save();
    // 1) Clip to the inner shape (so we only draw inside)
    canvas.clipRRect(rrect);

    // 2) Create a path that is the "inverse" (Everything EXCEPT the button)
    // We make a large rectangle somewhat larger than the button to ensure the blur doesn't show at the outer edges
    final outerRect = rect.inflate(blur + offset.distance + 20);
    final outerPath = Path()
      ..addRect(outerRect)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    // 3) Draw the shadow of this inverse path
    final shadowPaint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, _sigma(blur));

    canvas.translate(offset.dx, offset.dy);
    canvas.drawPath(outerPath, shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.blur != blur ||
        oldDelegate.offset != offset ||
        oldDelegate.borderRadius != borderRadius;
  }
}
