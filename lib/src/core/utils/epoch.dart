// The API sends epoch seconds; anything this large can only be milliseconds.
const _largestSecondsValue = 100000000000;

DateTime dateTimeFromEpoch(num value) {
  final millis = value.abs() < _largestSecondsValue ? value * 1000 : value;
  return DateTime.fromMillisecondsSinceEpoch(millis.round());
}
