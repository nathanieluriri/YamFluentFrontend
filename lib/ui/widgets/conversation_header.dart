import 'package:flutter/material.dart';

class ConversationHeader extends StatelessWidget {
  final String title;
  final String elapsedText;
  final double progress;
  final VoidCallback onClose;
  final VoidCallback onPause;

  const ConversationHeader({
    super.key,
    required this.title,
    required this.elapsedText,
    required this.progress,
    required this.onClose,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      elapsedText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.pause_circle_outline),
                      onPressed: onPause,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 4,
                color: Colors.white.withOpacity(0.35),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0, 1),
                  child: Container(height: 4, color: const Color(0xFF2EA9DE)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
