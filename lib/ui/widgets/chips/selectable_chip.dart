import 'package:flutter/material.dart';

class SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color borderColor;

  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = const Color(0xFFE7F4FB),
    this.selectedTextColor = const Color(0xFF2EA9DE),
    this.borderColor = const Color(0xFF2EA9DE),
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(24));
    final background =
        selected ? const Color(0xFFFFFFFF) : const Color(0xADF8F8F8);
    final shadows = selected
        ? const [
            BoxShadow(
              color: Color(0xFF2EA9DE),
              offset: Offset(0, 1),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(-2, 4),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          scale: selected ? 1.02 : 1.0,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: radius,
                  border: selected
                      ? const Border.fromBorderSide(
                          BorderSide(color: Color(0xFF2FA8EA), width: 1),
                        )
                      : null,
                  boxShadow: shadows,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected ? selectedTextColor : Colors.black87,
                      ) ??
                      TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? selectedTextColor : Colors.black87,
                      ),
                  child: Text(label),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: radius,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeOut,
                      child: selected
                          ? const DecoratedBox(
                              key: ValueKey('active'),
                              // Simulate inset highlight with a top-down gradient overlay.
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x152EA9DE),
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.5],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('inactive')),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
