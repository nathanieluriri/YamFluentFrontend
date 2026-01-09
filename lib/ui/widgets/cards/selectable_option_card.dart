import 'package:flutter/material.dart';

class SelectableOptionCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SelectableOptionCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  static const _blue = Color(0xFF2EA9DE);
  static const _borderBlue = Color(0xFF2FA8EA);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16); // keep original sizing feel

    final background = selected
        ? const Color(0xFFFFFFFF)
        : const Color(0xADF8F8F8);

    // Hard base shadow like your chip (tweak offset to taste)
    final shadows = selected
        ? const [
            BoxShadow(
              color: _blue,
              offset: Offset(0, 2),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 6),
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          scale: selected ? 1.01 : 1.0,
          child: Stack(
            children: [
              // Base card (this keeps the SAME width behavior as before)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(16), // keep original padding
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: radius,
                  border: selected
                      ? Border.all(color: _borderBlue, width: 1)
                      : null,
                  boxShadow: shadows,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(child: leading),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600) ??
                                const TextStyle(fontWeight: FontWeight.w600),
                            child: Text(title),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            style: Theme.of(context).textTheme.bodySmall ??
                                const TextStyle(),
                            child: Text(subtitle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Inset-ish overlay (like your chip)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: radius,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: selected
                              ? const [
                                  Color(0x192EA9DE), // subtle blue tint
                                  Color(0x252EA9DE),
                                ]
                              : const [
                                  Color(0x01FFFFFF), // subtle white highlight
                                  Colors.transparent,
                                ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
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
