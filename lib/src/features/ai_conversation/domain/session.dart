import 'message.dart';
import 'turn.dart';

enum SessionStatus { idle, starting, inConversation, ending, feedbackReady, error }

class Session {
  final String id;
  final String scenarioId;
  final String userId;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic> adaptiveParams; // difficulty, speed, etc.
  final List<Message> messages;
  final List<Turn> turns;
  final int totalTurns;
  final double? averageScore;
  final bool completed;
  final DateTime? lastUpdated;

  const Session({
    required this.id,
    required this.scenarioId,
    required this.userId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.adaptiveParams = const {},
    this.messages = const [],
    this.turns = const [],
    this.totalTurns = 0,
    this.averageScore,
    this.completed = false,
    this.lastUpdated,
  });

  Session copyWith({
    String? id,
    String? scenarioId,
    String? userId,
    SessionStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? adaptiveParams,
    List<Message>? messages,
    List<Turn>? turns,
    int? totalTurns,
    double? averageScore,
    bool? completed,
    DateTime? lastUpdated,
  }) {
    return Session(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      adaptiveParams: adaptiveParams ?? this.adaptiveParams,
      messages: messages ?? this.messages,
      turns: turns ?? this.turns,
      totalTurns: totalTurns ?? this.totalTurns,
      averageScore: averageScore ?? this.averageScore,
      completed: completed ?? this.completed,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isReadyForCoachingTip {
    if (turns.isEmpty) {
      return completed;
    }
    return turns.every((turn) => turn.isComplete);
  }
}
