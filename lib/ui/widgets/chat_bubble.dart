import 'package:flutter/material.dart';

import 'speaker_button.dart';

class ChatBubble extends StatelessWidget {
  final Widget textWidget;
  final bool isUser;
  final DateTime timestamp;
  final bool showSpeaker;
  final bool isPlaying;
  final VoidCallback? onSpeakerPressed;
  final Key? speakerKey;

  const ChatBubble({
    super.key,
    required this.textWidget,
    required this.isUser,
    required this.timestamp,
    required this.showSpeaker,
    required this.isPlaying,
    required this.onSpeakerPressed,
    this.speakerKey,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? const Color(0xFFE7EEF8) : Colors.white;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final timeText = _formatTimestamp(timestamp);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  textWidget,
                  const SizedBox(height: 6),
                  Text(
                    timeText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
            if (showSpeaker && onSpeakerPressed != null)
              Positioned(
                right: isUser ? -6 : null,
                left: isUser ? null : -6,
                top: 4,
                child: SpeakerButton(
                  key: speakerKey,
                  isPlaying: isPlaying,
                  onPressed: onSpeakerPressed!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }
}
