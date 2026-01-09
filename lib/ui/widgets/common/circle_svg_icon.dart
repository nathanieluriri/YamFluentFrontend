import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircleSvgIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color background;

  const CircleSvgIcon({
    super.key,
    required this.asset,
    this.size = 32,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SvgPicture.asset(asset),
    );
  }
}
