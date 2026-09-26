import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam_fluent/src/core/network/dio_provider.dart';
import 'package:yam_fluent/src/features/feedback/presentation/session_complete_screen.dart';

import 'support/fake_api.dart';

Map<String, Object?> _session(List<int> hesitations) {
  final turns = <Map<String, Object?>>[
    {'index': 0, 'role': 'ai', 'text': 'Tell me about yourself.'},
  ];
  for (final hesitation in hesitations) {
    turns
      ..add({
        'index': turns.length,
        'role': 'user',
        'text': 'I have five years of experience.',
        'score': {'confidence': 90, 'fluency': 88, 'hesitation': hesitation},
      })
      ..add({'index': turns.length, 'role': 'ai', 'text': 'Thank you.'});
  }
  return {
    'id': 's1',
    'scenario': 'job_interview',
    'userId': 'u1',
    'script': {'totalNumberOfTurns': turns.length, 'turns': turns},
    'averageScore': 90.0,
    'completed': true,
    'dateCreated': 1790455260,
    'lastUpdated': 1790455260 + 92,
  };
}

Future<void> _pumpSummary(WidgetTester tester, List<int> hesitations) async {
  final api = FakeApi((_) => _session(hesitations));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dioProvider.overrideWithValue(api.dio)],
      child: const MaterialApp(
        home: SessionCompleteScreen(
          sessionId: 's1',
          confidence: 0,
          fluency: 0,
          hesitation: 0,
        ),
      ),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('the session summary names the scenario and its most hesitant '
      'turn', (tester) async {
    await _pumpSummary(tester, [100, 75, 90]);
    expect(find.text('Job Interview'), findsOneWidget);
    expect(find.text('1m 32s'), findsOneWidget);
    expect(find.text('Most hesitant: Turn 3 (75%)'), findsOneWidget);
  });

  testWidgets('a session without hesitation names no most hesitant turn', (
    tester,
  ) async {
    await _pumpSummary(tester, [100, 100]);
    expect(find.textContaining('Most hesitant'), findsNothing);
  });
}
