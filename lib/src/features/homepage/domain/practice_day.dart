/// Which day of the learner's streak today is: 1 plus the unbroken run of
/// practice days just before today.
int practiceDayNumber(Iterable<DateTime> practicedAt, DateTime now) {
  final days = {
    for (final time in practicedAt) DateTime(time.year, time.month, time.day),
  };
  var dayNumber = 1;
  var day = DateTime(now.year, now.month, now.day - 1);
  while (days.contains(day)) {
    dayNumber++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return dayNumber;
}
