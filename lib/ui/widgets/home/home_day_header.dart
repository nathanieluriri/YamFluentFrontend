import 'package:flutter/material.dart';
import '../common/circle_svg_icon.dart';

class HomeDayHeader extends StatelessWidget {
  final String dayLabel;

  const HomeDayHeader({super.key, this.dayLabel = 'Day 1'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleSvgIcon(asset: 'assets/icons/fire.svg', size: 40),
        const SizedBox(width: 10),
        Text(
          dayLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0C1A1E),
          ),
        ),
      ],
    );
  }
}
