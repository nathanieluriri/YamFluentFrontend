import 'dart:math' as math;
import 'package:flutter/material.dart';

class YamFluentLoader extends StatefulWidget {
  final double dotSize;
  final double radius;
  final Duration period;
  final bool isComplete;
  final Duration completeDuration;
  final Curve curve;
  final Alignment alignment;
  final bool isLeftAligned;

  const YamFluentLoader({
    super.key,
    this.dotSize = 32,
    this.radius = 20,
    this.period = const Duration(seconds: 1),
    this.isComplete = false,
    this.completeDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
    this.isLeftAligned = false,
  });

  @override
  State<YamFluentLoader> createState() => _YamFluentLoaderState();
}

class _YamFluentLoaderState extends State<YamFluentLoader>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _completeController;
  double _completionStartAngle = -math.pi / 2;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
    _completeController = AnimationController(
      vsync: this,
      duration: widget.completeDuration,
    );
  }

  @override
  void didUpdateWidget(covariant YamFluentLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _orbitController.duration = widget.period;
      if (!_orbitController.isAnimating && !widget.isComplete) {
        _orbitController.repeat();
      }
    }
    if (oldWidget.isComplete != widget.isComplete) {
      if (widget.isComplete) {
        _completionStartAngle = _currentAngle;
        _orbitController.stop();
        _completeController.forward(from: 0);
      } else {
        _completeController.reset();
        _orbitController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  double get _currentAngle {
    final eased = widget.curve.transform(_orbitController.value);
    return -math.pi / 2 + (math.pi * 2 * eased);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2 + widget.dotSize;
    final effectiveAlignment = widget.isLeftAligned
        ? Alignment.centerLeft
        : widget.alignment;
    return Align(
      alignment: effectiveAlignment,
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_orbitController, _completeController]),
          builder: (context, _) {
            final completionT = _completeController.value;
            final angle = widget.isComplete
                ? _completionStartAngle
                : _currentAngle;
            final darkOffset = Offset(
              widget.radius * math.cos(angle),
              widget.radius * math.sin(angle),
            );
            final lightOffset = Offset(
              widget.radius * math.cos(angle + math.pi),
              widget.radius * math.sin(angle + math.pi),
            );

            final mergedDark = Offset.lerp(
              darkOffset,
              Offset.zero,
              completionT,
            )!;
            final mergedLight = Offset.lerp(
              lightOffset,
              Offset.zero,
              completionT,
            )!;

            final depthScaleDark = _depthScale(mergedDark.dy);
            final depthScaleLight = _depthScale(mergedLight.dy);
            final lightFade = (1 - completionT).clamp(0.0, 1.0);
            final lightScale = depthScaleLight * (1 - 0.2 * completionT);

            final darkWidget = Transform.translate(
              offset: mergedDark,
              child: Transform.scale(
                scale: depthScaleDark,
                child: _Dot(
                  size: widget.dotSize,
                  color: const Color(0xFF011A25),
                ),
              ),
            );

            final lightWidget = Transform.translate(
              offset: mergedLight,
              child: Transform.scale(
                scale: lightScale,
                child: Opacity(
                  opacity: lightFade,
                  child: _Dot(
                    size: widget.dotSize,
                    color: const Color(0xFFBEE9FC),
                  ),
                ),
              ),
            );

            final lightOnTop = mergedLight.dy > mergedDark.dy;
            return Stack(
              alignment: Alignment.center,
              children: lightOnTop
                  ? [darkWidget, lightWidget]
                  : [lightWidget, darkWidget],
            );
          },
        ),
      ),
    );
  }

  double _depthScale(double y) {
    final radius = widget.radius == 0 ? 1 : widget.radius;
    final normalized = (y / radius).clamp(-1.0, 1.0);
    return 1.0 + (0.05 * normalized);
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;

  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
