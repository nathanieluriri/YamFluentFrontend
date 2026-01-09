import 'package:flutter/material.dart';
import '../loaders/yamfluent_loader_inline.dart';

class ChangeScenarioRow extends StatelessWidget {
  final bool isLoading;
  final String? errorText;
  final VoidCallback onTap;

  const ChangeScenarioRow({
    super.key,
    required this.isLoading,
    required this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2EA9DE);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Change Scenario',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: accent,
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: FittedBox(
                    child: YamFluentLoaderInline(),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Loading scenarios...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: const TextStyle(
                color: Color(0xFFB3261E),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
