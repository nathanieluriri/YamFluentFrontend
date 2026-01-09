class Progress {
  final String userId;
  final int currentStreak;
  final int totalSessions;
  final double averageFluencyScore;
  final List<DateTime> activeDays;

  const Progress({
    required this.userId,
    required this.currentStreak,
    required this.totalSessions,
    required this.averageFluencyScore,
    required this.activeDays,
  });
}
