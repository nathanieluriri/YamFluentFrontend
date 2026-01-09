import 'package:flutter/material.dart';

class TertiaryActionButton extends StatelessWidget {
  final String label;
  final String actionText;
  final VoidCallback onPressed;
  final Color actionColor;
  final TextStyle? labelStyle;
  final TextStyle? actionStyle;
  final MainAxisAlignment alignment;
  final double spacing;

  const TertiaryActionButton({
    super.key,
    required this.label,
    required this.actionText,
    required this.onPressed,
    this.actionColor = const Color(0xFF2EA9DE),
    this.labelStyle,
    this.actionStyle,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    final wrapAlignment = _toWrapAlignment(alignment);
    final defaultLabelStyle = labelStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith();

    final defaultActionStyle = actionStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: actionColor,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: actionColor,
            );

    return Center(
      child: Wrap(
        alignment: wrapAlignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        children: [
          Text(label, style: defaultLabelStyle),
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(actionText, style: defaultActionStyle),
            ),
          ),
        ],
      ),
    );
  }

  WrapAlignment _toWrapAlignment(MainAxisAlignment value) {
    switch (value) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }
}
