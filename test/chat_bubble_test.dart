import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam_fluent/ui/widgets/chat_bubble.dart';
import 'package:yam_fluent/ui/widgets/speaker_button.dart';

void main() {
  testWidgets('the speaker badge sits beside a bubble\'s text, not over it', (
    tester,
  ) async {
    for (final isUser in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ChatBubble(
                textWidget: const Text('Say experience like this.'),
                isUser: isUser,
                timestamp: DateTime(2026, 9, 26, 20, 41),
                showSpeaker: true,
                isPlaying: false,
                onSpeakerPressed: () {},
              ),
            ),
          ),
        ),
      );
      final text = tester.getRect(find.text('Say experience like this.'));
      final badge = tester.getRect(find.byType(SpeakerButton));
      expect(text.overlaps(badge), isFalse, reason: 'isUser: $isUser');
    }
  });
}
