import 'turn_score.dart';

class Turn {
  final int index;
  final String role;
  final String text;
  final TurnScore? score;
  final List<String> mispronouncedWords;
  final String? modelAudioUrl;
  final String? userAudioUrl;
  final Map<String, dynamic>? speechAnalysis;

  const Turn({
    required this.index,
    required this.role,
    required this.text,
    this.score,
    this.mispronouncedWords = const [],
    this.modelAudioUrl,
    this.userAudioUrl,
    this.speechAnalysis,
  });

  bool get isUser => role == 'user';

  bool get isComplete {
    if (!isUser) return true;
    return score != null && (userAudioUrl?.isNotEmpty ?? false);
  }
}
