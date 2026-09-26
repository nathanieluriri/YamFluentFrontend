import 'package:flutter_test/flutter_test.dart';
import 'package:yam_fluent/src/core/utils/epoch.dart';
import 'package:yam_fluent/src/features/ai_conversation/data/session_dto.dart';
import 'package:yam_fluent/src/features/coaching_tips/data/coaching_tip_dto.dart';
import 'package:yam_fluent/src/features/practice_history/data/practice_history_api.dart';

import 'support/fake_api.dart';

// 26 September 2026, 20:41:00 UTC, as the API sends it (seconds).
const _seconds = 1790455260;
final _moment = DateTime.utc(2026, 9, 26, 20, 41);

void main() {
  test('epoch seconds and milliseconds both read as the same moment', () {
    expect(dateTimeFromEpoch(_seconds).toUtc(), _moment);
    expect(dateTimeFromEpoch(_seconds * 1000).toUtc(), _moment);
  });

  test('a session reads its timestamps as seconds', () {
    final session = SessionDTO.fromJson({
      'id': 's1',
      'scenario': 'job_interview',
      'userId': 'u1',
      'dateCreated': _seconds,
      'lastUpdated': _seconds + 92,
    });
    expect(session.dateCreated!.toUtc(), _moment);
    expect(
      session.lastUpdated!.difference(session.dateCreated!),
      const Duration(seconds: 92),
    );
  });

  test('a coaching tip reads its timestamp as seconds', () {
    final tip = CoachingTipListItemDTO.fromJson({
      'id': 't1',
      'sessionId': 's1',
      'createdAt': _seconds,
    });
    expect(tip.createdAt!.toUtc(), _moment);
  });

  test('practice history reads its timestamps as seconds', () async {
    final api = FakeApi(
      (_) => [
        {
          'id': 's1',
          'scenario': 'job_interview',
          'lastUpdated': _seconds,
          'averageScore': 90.5,
          'totalNumberOfTurns': 11,
        },
      ],
    );
    final sessions = await PracticeHistoryApi(api.dio).listSessions();
    expect(sessions.single.lastUpdated!.toUtc(), _moment);
  });
}
