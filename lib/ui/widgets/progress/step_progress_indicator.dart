import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int total;
  final int currentIndex;
  final String activeIconPath;
  final Color completedColor;
  final Color inactiveColor;
  final Color activeBackgroundColor;

  const StepProgressIndicator({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.activeIconPath,
    this.completedColor = const Color(0xFF124B5A),
    this.inactiveColor = const Color(0xFFD9D9D9),
    this.activeBackgroundColor = const Color(0xFFE7F4FB),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index == currentIndex;
        final isComplete = index < currentIndex;
        if (isActive) {
          return Container(
            height: 22,
            width: 22,
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              color: activeBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Image.asset(activeIconPath),
            ),
          );
        }
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            color: isComplete ? completedColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
