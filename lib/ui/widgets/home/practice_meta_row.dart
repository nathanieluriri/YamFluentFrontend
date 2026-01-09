import 'package:flutter/material.dart';
import '../common/dot.dart';
import 'home_style_helpers.dart';

class PracticeMetaRow extends StatelessWidget {
  final String difficultyLabel;
  final int difficultyRating;

  const PracticeMetaRow({
    super.key,
    required this.difficultyLabel,
    required this.difficultyRating,
  });

  @override
  Widget build(BuildContext context) {
    final color = difficultyColor(difficultyRating);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/clock.png',
          height: 30,
          width: 30,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.calendar_today,
            size: 24,
            color: Color(0xFF2EA9DE),
          ),
        ),

        const SizedBox(width: 10),
        const Text(
          '5 minutes',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0C1A1E),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        const Dot(),
        const SizedBox(width: 10),
        Text(
          difficultyLabel,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
