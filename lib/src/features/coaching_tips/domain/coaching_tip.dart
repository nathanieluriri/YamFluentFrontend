class CoachingTip {
  final String id;
  final String sessionId;
  final String userId;
  final DateTime? createdAt;
  final String tipText;
  final List<String> practiceWords;
  final Map<String, dynamic>? providerMeta;
  final String? feedback;
  final String? promptVersion;

  const CoachingTip({
    required this.id,
    required this.sessionId,
    required this.userId,
    this.createdAt,
    required this.tipText,
    this.practiceWords = const [],
    this.providerMeta,
    this.feedback,
    this.promptVersion,
  });
}
