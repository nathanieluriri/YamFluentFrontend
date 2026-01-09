import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final String text;
  final Color lineColor;
  final double thickness;
  final double horizontalPadding;
  final double textPadding;
  final TextStyle? textStyle;

  const OrDivider({
    super.key,
    this.text = 'or',
    this.lineColor = const Color(0xFFD0D0D0),
    this.thickness = 1,
    this.horizontalPadding = 0,
    this.textPadding = 12,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: lineColor,
              thickness: thickness,
              height: thickness,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: textPadding),
            child: Text(text, style: style),
          ),
          Expanded(
            child: Divider(
              color: lineColor,
              thickness: thickness,
              height: thickness,
            ),
          ),
        ],
      ),
    );
  }
}
