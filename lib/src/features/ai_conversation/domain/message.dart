class Message {
  final String id;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}
