import 'package:flutter/material.dart';

class ScenarioChip extends StatelessWidget {
  final String label;

  const ScenarioChip({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width - 90;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth.clamp(140.0, 320.0).toDouble(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F4FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2EA9DE)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF2EA9DE),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
