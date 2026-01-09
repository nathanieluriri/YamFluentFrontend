class FeedbackEntity {
  final String id;
  final String sessionId;
  final double pronunciationScore;
  final double vocabularyScore;
  final double confidenceScore;
  final int hesitationCount;
  final List<String> coachNotes;
  final List<String> nextSteps;

  const FeedbackEntity({
    required this.id,
    required this.sessionId,
    required this.pronunciationScore,
    required this.vocabularyScore,
    required this.confidenceScore,
    required this.hesitationCount,
    required this.coachNotes,
    required this.nextSteps,
  });
}
