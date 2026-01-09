import 'package:flutter/material.dart';

class ScoreRow extends StatelessWidget {
  final double confidence;
  final double fluency;
  final double hesitation;

  const ScoreRow({
    super.key,
    required this.confidence,
    required this.fluency,
    required this.hesitation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ScorePill(
          color: const Color(0xFF2EA9DE),
          value: confidence,
        ),
        const SizedBox(width: 12),
        _ScorePill(
          color: const Color(0xFF342EDE),
          value: fluency,
        ),
        const SizedBox(width: 12),
        _ScorePill(
          color: const Color(0xFF9D2EDE),
          value: hesitation,
        ),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  final Color color;
  final double value;

  const _ScorePill({
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.32),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
