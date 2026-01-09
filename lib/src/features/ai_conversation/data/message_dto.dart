import '../domain/message.dart';

class MessageDTO {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;

  const MessageDTO({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory MessageDTO.fromJson(Map<String, dynamic> json) {
    final id = _string(json['id']) ?? _string(json['index']) ?? '';
    final role = _string(json['role']) ?? 'ai';
    final content = _string(json['text']) ?? _string(json['content']) ?? '';
    final timestamp = _parseDate(json['timestamp']) ?? _parseDate(json['createdAt']) ?? DateTime.now();
    return MessageDTO(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      role: role,
      content: content,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Message toDomain() {
    return Message(
      id: id,
      role: role,
      content: content,
      timestamp: timestamp,
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
