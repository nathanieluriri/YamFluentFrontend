class Message {
  final String id;
  final String role; 
  final String content;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}
