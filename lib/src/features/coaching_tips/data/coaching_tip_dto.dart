class CoachingTipListItemDTO {
  final String id;
  final String sessionId;
  final DateTime? createdAt;
  final String? preview;

  const CoachingTipListItemDTO({
    required this.id,
    required this.sessionId,
    this.createdAt,
    this.preview,
  });

  factory CoachingTipListItemDTO.fromJson(Map<String, dynamic> json) {
    return CoachingTipListItemDTO(
      id: _string(json['id']) ?? '',
      sessionId: _string(json['sessionId'] ?? json['session_id']) ?? '',
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      preview: _string(json['preview']),
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class CoachingTipDTO {
  final String id;
  final String sessionId;
  final String userId;
  final DateTime? createdAt;
  final String tipText;
  final List<String>? practiceWords;
  final Map<String, dynamic>? providerMeta;
  final String? feedback;
  final String? promptVersion;

  const CoachingTipDTO({
    required this.id,
    required this.sessionId,
    required this.userId,
    this.createdAt,
    required this.tipText,
    this.practiceWords,
    this.providerMeta,
    this.feedback,
    this.promptVersion,
  });

  factory CoachingTipDTO.fromJson(Map<String, dynamic> json) {
    return CoachingTipDTO(
      id: CoachingTipListItemDTO._string(json['id']) ?? '',
      sessionId: CoachingTipListItemDTO._string(json['sessionId'] ?? json['session_id']) ?? '',
      userId: CoachingTipListItemDTO._string(json['userId'] ?? json['user_id']) ?? '',
      createdAt: CoachingTipListItemDTO._parseDate(json['createdAt'] ?? json['created_at']),
      tipText: CoachingTipListItemDTO._string(json['tipText'] ?? json['tip_text']) ?? '',
      practiceWords: _stringList(json['practiceWords'] ?? json['practice_words']),
      providerMeta: _asMap(json['providerMeta'] ?? json['provider_meta']),
      feedback: CoachingTipListItemDTO._string(json['feedback']),
      promptVersion: CoachingTipListItemDTO._string(json['promptVersion'] ?? json['prompt_version']),
    );
  }

  static List<String>? _stringList(Object? value) {
    if (value is List) {
      final items = value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
      return items.isEmpty ? null : items;
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }
}
