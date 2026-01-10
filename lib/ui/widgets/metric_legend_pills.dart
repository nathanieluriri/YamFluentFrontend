import 'package:flutter/material.dart';

class MetricLegendPills extends StatelessWidget {
  const MetricLegendPills({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(44),
        border: const Border(
          top: BorderSide(
            color: Colors.white,
            width: 1.0, 
          ),
          bottom: BorderSide(
            color: Colors.white,
            width: 2.0, 
          ),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 38,
          children: const [
            _LegendPill(label: 'Confidence', color: Color(0x352EA9DE)),
            _LegendPill(label: 'Fluency', color: Color(0x35342EDE)),
            _LegendPill(label: 'Hesitation', color: Color(0x359D2EDE)),
          ],
        ),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
