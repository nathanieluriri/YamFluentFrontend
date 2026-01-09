import 'dart:math';

import 'package:flutter/material.dart';

class WaveformBars extends StatelessWidget {
  final double amplitude;

  const WaveformBars({
    super.key,
    required this.amplitude,
  });

  @override
  Widget build(BuildContext context) {
    final baseHeights = [0.3, 0.6, 1.0, 0.6, 0.3];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: baseHeights.map((base) {
        final height = 8 + (24 * base * max(amplitude, 0.1));
        return Container(
          width: 6,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF2EA9DE),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }
}
