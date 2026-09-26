import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../practice_history/presentation/practice_history_controller.dart';
import '../../settings/domain/settings_enums.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/practice_day.dart';

final homePracticeDayProvider = Provider<int>((ref) {
  final sessions = ref.watch(
    practiceHistoryControllerProvider.select(
      (state) => state.sessions.valueOrNull,
    ),
  );
  return practiceDayNumber(
    (sessions ?? const [])
        .map((session) => session.lastUpdated)
        .whereType<DateTime>(),
    DateTime.now(),
  );
});

final homeDailyMinutesProvider = Provider<int>((ref) {
  final time = ref.watch(
    settingsControllerProvider.select(
      (settings) => settings.valueOrNull?.studyAvailability.dailyPracticeTime,
    ),
  );
  return (time ?? DailyPracticeTime.mins5).minutes;
});
