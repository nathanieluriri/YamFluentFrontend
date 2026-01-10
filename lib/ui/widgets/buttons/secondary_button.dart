import 'package:flutter/material.dart';



class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.leading,
    this.height = 58,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.borderColor = Colors.black26,
    this.borderWidth = 1.0,
    this.backgroundColor = Colors.transparent,
    this.disabledOpacity = 0.45,
    this.gap = 12,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? leading;

  final double height;
  final double? width;
  final EdgeInsets padding;

  final BorderRadius borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;

  final double disabledOpacity;
  final double gap;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final base = ClipRRect(
      borderRadius: widget.borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),

        ),
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: Padding(
            padding: widget.padding,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    SizedBox(width: widget.gap),
                  ],
                  Flexible(child: widget.child),
                ],
              ),
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
            if (enabled)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: _pressed ? 0.06 : 0.0,
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
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: content,
      ),
    );
  }
}
