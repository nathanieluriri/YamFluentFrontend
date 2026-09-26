import 'package:flutter_test/flutter_test.dart';
import 'package:yam_fluent/src/features/homepage/domain/practice_day.dart';
import 'package:yam_fluent/src/features/settings/domain/settings_enums.dart';

void main() {
  final now = DateTime(2026, 10, 3, 20, 41);
  DateTime daysAgo(int days, {int hour = 19}) =>
      DateTime(now.year, now.month, now.day - days, hour);

  test('a new learner is on day 1', () {
    expect(practiceDayNumber(const [], now), 1);
  });

  test('each unbroken day before today adds one', () {
    expect(practiceDayNumber([daysAgo(1), daysAgo(2)], now), 3);
    expect(practiceDayNumber([daysAgo(0), daysAgo(1), daysAgo(2)], now), 3);
  });

  test('several sessions on one day count once', () {
    expect(
      practiceDayNumber([daysAgo(1, hour: 8), daysAgo(1, hour: 21)], now),
      2,
    );
  });

  test('a missed day starts the count again', () {
    expect(practiceDayNumber([daysAgo(0)], now), 1);
    expect(practiceDayNumber([daysAgo(2), daysAgo(3)], now), 1);
  });

  test('daily practice times give their minutes', () {
    expect(DailyPracticeTime.values.map((time) => time.minutes), [
      5,
      10,
      12,
      15,
      20,
    ]);
  });
}
