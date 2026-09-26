import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam_fluent/src/core/network/dio_provider.dart';
import 'package:yam_fluent/src/features/authentication/domain/user.dart';
import 'package:yam_fluent/src/features/authentication/presentation/user_profile_store.dart';
import 'package:yam_fluent/src/features/homepage/presentation/home_progress_providers.dart';
import 'package:yam_fluent/src/features/settings/data/settings_local_data_source.dart';

import 'support/fake_api.dart';

class _MemorySettings implements SettingsLocalDataSource {
  @override
  Future<String> getOrCreateDeviceId() async => 'device_test';
  @override
  Future<bool> getThemeMode() async => false;
  @override
  Future<void> saveThemeMode(bool isDarkMode) async {}
}

User _learner(String id) =>
    User(id: id, email: '$id@example.com', onboardingCompleted: true);

int _secondsAgo(Duration ago) =>
    DateTime.now().subtract(ago).millisecondsSinceEpoch ~/ 1000;

Future<void> _until(bool Function() done) async {
  for (var i = 0; i < 400 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(done(), isTrue);
}

void main() {
  test('Home shows the learner\'s daily time and day, and a new sign-in '
      'reloads both', () async {
    var learner = 'tolu';
    final api = FakeApi((request) {
      if (request.path == '/v1/users/settings/') {
        return {
          'studyAvailability': {
            'dailyPracticeTime': learner == 'tolu' ? '10 mins' : '15 mins',
          },
        };
      }
      if (learner != 'tolu') return <Object>[];
      return [
        for (final days in [1, 2])
          {
            'id': 'session-$days',
            'scenario': 'cafe_ordering',
            'lastUpdated': _secondsAgo(Duration(days: days)),
          },
      ];
    });
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(api.dio),
        settingsLocalDataSourceProvider.overrideWithValue(_MemorySettings()),
      ],
    );
    addTearDown(container.dispose);
    final profile = container.read(userProfileStoreProvider.notifier);
    profile.setUser(_learner('tolu'));
    container.listen(homeDailyMinutesProvider, (_, __) {});
    container.listen(homePracticeDayProvider, (_, __) {});

    await _until(
      () =>
          container.read(homeDailyMinutesProvider) == 10 &&
          container.read(homePracticeDayProvider) == 3,
    );

    profile.clear();
    learner = 'ada';
    profile.setUser(_learner('ada'));

    await _until(
      () =>
          container.read(homeDailyMinutesProvider) == 15 &&
          container.read(homePracticeDayProvider) == 1,
    );
  });
}
