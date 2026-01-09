import 'package:flutter/material.dart';
import '../common/inner_shadow.dart';

/// Primary pill button with shimmer sweep + inner shadow + press animations.
/// Renamed from PrimaryShimmerButton to PrimaryButton for generic usage.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 58,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.backgroundColor = const Color(0xFF2EA9DE),
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.innerShadowColor = const Color(0xCCFFFFFF), // Strong white inner shadow (80%)
    this.innerShadowBlur = 10,
    this.innerShadowOffset = const Offset(0, 3), // Top highlight
    this.enableShimmer = true,
    this.shimmerDuration = const Duration(milliseconds: 1800),
    this.disabledOpacity = 0.45,
  });

  final VoidCallback? onPressed;
  final Widget child;

  final double height;
  final double? width;
  final EdgeInsets padding;

  final Color backgroundColor;
  final BorderRadius borderRadius;

  // Inner shadow spec
  final Color innerShadowColor;
  final double innerShadowBlur;
  final Offset innerShadowOffset;

  // Shimmer
  final bool enableShimmer;
  final Duration shimmerDuration;

  final double disabledOpacity;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(vsync: this, duration: widget.shimmerDuration);
    if (widget.enableShimmer) _shimmerCtrl.repeat();
  }

  @override
  void didUpdateWidget(covariant PrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableShimmer != widget.enableShimmer ||
        oldWidget.shimmerDuration != widget.shimmerDuration) {
      _shimmerCtrl.duration = widget.shimmerDuration;
      if (widget.enableShimmer) {
        _shimmerCtrl.repeat();
      } else {
        _shimmerCtrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final base = ClipRRect(
      borderRadius: widget.borderRadius,
      child: InnerShadow(
        color: widget.innerShadowColor,
        blur: widget.innerShadowBlur,
        offset: widget.innerShadowOffset,
        borderRadius: widget.borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
            // soft outer highlight (helps match the screenshot’s glossy top edge)
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 6),
                color: Color(0x14000000), // Dark soft shadow
              ),
            ],
          ),
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: Padding(
              padding: widget.padding,
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );

    final content = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed ? 0.985 : 1.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : widget.disabledOpacity,
        child: Stack(
          children: [
            base,

            // Shimmer overlay (does NOT turn the button white)
            if (widget.enableShimmer && enabled)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: AnimatedBuilder(
                    animation: _shimmerCtrl,
                    builder: (context, _) {
                      final t = _shimmerCtrl.value; // 0..1
                      final slide = (t * 2) - 0.5; // -0.5 .. 1.5 (so it fully passes)

                      return Transform.translate(
                        offset: Offset(widget.width == null ? 0 : 0, 0),
                        child: FractionalTranslation(
                          translation: Offset(slide, 0),
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.35, // tweak highlight strength
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(-1.0, -0.3),
                                    end: Alignment(1.0, 0.3),
                                    stops: const [0.0, 0.5, 1.0],
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.22),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Press highlight overlay
            if (enabled)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: _pressed ? 0.10 : 0.0,
                    child: Container(color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTapUp: enabled
            ? (_) {
                _setPressed(false);
              }
            : null,
        onTap: enabled ? widget.onPressed : null,
        child: content,
      ),
    );
  }
}
