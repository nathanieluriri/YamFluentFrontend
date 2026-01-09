import 'package:flutter/material.dart';

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF9CA3AF),
        shape: BoxShape.circle,
      ),
    );
  }
}
