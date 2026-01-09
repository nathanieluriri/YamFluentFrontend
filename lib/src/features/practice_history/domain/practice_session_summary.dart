class PracticeSessionSummary {
  final String id;
  final String scenario;
  final DateTime? lastUpdated;
  final double? averageScore;
  final int? totalTurns;

  const PracticeSessionSummary({
    required this.id,
    required this.scenario,
    this.lastUpdated,
    this.averageScore,
    this.totalTurns,
  });

  String get scenarioLabel {
    if (scenario.isEmpty) return 'Practice';
    final words = scenario.replaceAll('_', ' ').split(' ');
    return words
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
