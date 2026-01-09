import '../domain/message.dart';
import '../domain/session.dart';
import '../domain/turn.dart';
import '../domain/turn_score.dart';

class SessionDTO {
  final String id;
  final String scenario;
  final String userId;
  final FluencyScriptDTO? script;
  final double? averageScore;
  final bool completed;
  final DateTime? dateCreated;
  final DateTime? lastUpdated;

  const SessionDTO({
    required this.id,
    required this.scenario,
    required this.userId,
    this.script,
    this.averageScore,
    required this.completed,
    this.dateCreated,
    this.lastUpdated,
  });

  factory SessionDTO.fromJson(Map<String, dynamic> json) {
    final scriptJson = _asMap(json['script']);
    return SessionDTO(
      id: _string(json['id']) ?? '',
      scenario: _string(json['scenario']) ?? '',
      userId: _string(json['userId'] ?? json['user_id']) ?? '',
      script: scriptJson == null ? null : FluencyScriptDTO.fromJson(scriptJson),
      averageScore: _doubleOrNull(json['averageScore'] ?? json['average_score']),
      completed: _boolOrFalse(json['completed']) ?? false,
      dateCreated: _parseDate(json['dateCreated'] ?? json['date_created']),
      lastUpdated: _parseDate(json['lastUpdated'] ?? json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario': scenario,
      'userId': userId,
      'script': script?.toJson(),
      'averageScore': averageScore,
      'completed': completed,
      'dateCreated': dateCreated?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  Session toDomain() {
    final turns = script?.turns ?? const <TurnDTO>[];
    final sortedTurns = List<TurnDTO>.from(turns)
      ..sort((a, b) => a.index.compareTo(b.index));
    final fallbackTime = dateCreated ?? DateTime.now();
    final messages = sortedTurns.map((turn) {
      return Message(
        id: 'turn-${turn.index}',
        role: turn.role,
        content: turn.text,
        timestamp: fallbackTime,
      );
    }).toList();

    final domainTurns = sortedTurns.map((turn) {
      return Turn(
        index: turn.index,
        role: turn.role,
        text: turn.text,
        score: turn.score == null
            ? null
            : TurnScore(
                confidence: turn.score!.confidence,
                fluency: turn.score!.fluency,
                hesitation: turn.score!.hesitation,
              ),
        mispronouncedWords: turn.mispronouncedWords ?? const [],
        modelAudioUrl: turn.modelAudioUrl,
        userAudioUrl: turn.userAudioUrl,
        speechAnalysis: turn.speechAnalysis?.toJson(),
      );
    }).toList();

    final adaptiveParams = <String, dynamic>{
      if (averageScore != null) 'averageScore': averageScore,
      if (script?.totalNumberOfTurns != null)
        'totalNumberOfTurns': script!.totalNumberOfTurns,
    };

    return Session(
      id: id,
      scenarioId: scenario,
      userId: userId,
      status: completed ? SessionStatus.feedbackReady : SessionStatus.inConversation,
      startedAt: dateCreated ?? DateTime.now(),
      endedAt: completed ? (lastUpdated ?? dateCreated) : null,
      adaptiveParams: adaptiveParams,
      messages: messages,
      turns: domainTurns,
      totalTurns: script?.totalNumberOfTurns ?? domainTurns.length,
      averageScore: averageScore,
      completed: completed,
      lastUpdated: lastUpdated,
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _intOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _doubleOrNull(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static bool? _boolOrFalse(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return null;
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }
}

class FluencyScriptDTO {
  final int totalNumberOfTurns;
  final List<TurnDTO> turns;

  const FluencyScriptDTO({
    required this.totalNumberOfTurns,
    required this.turns,
  });

  factory FluencyScriptDTO.fromJson(Map<String, dynamic> json) {
    final rawTurns = json['turns'];
    final turnList = rawTurns is List
        ? rawTurns.whereType<Map<String, dynamic>>().map(TurnDTO.fromJson).toList()
        : <TurnDTO>[];
    final total = SessionDTO._intOrNull(json['totalNumberOfTurns']) ?? turnList.length;
    return FluencyScriptDTO(
      totalNumberOfTurns: total,
      turns: turnList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalNumberOfTurns': totalNumberOfTurns,
      'turns': turns.map((turn) => turn.toJson()).toList(),
    };
  }
}

class TurnDTO {
  final int index;
  final String role;
  final String text;
  final TurnScoreDTO? score;
  final List<String>? mispronouncedWords;
  final String? modelAudioUrl;
  final String? userAudioUrl;
  final TurnSpeechAnalysisDTO? speechAnalysis;

  const TurnDTO({
    required this.index,
    required this.role,
    required this.text,
    this.score,
    this.mispronouncedWords,
    this.modelAudioUrl,
    this.userAudioUrl,
    this.speechAnalysis,
  });

  factory TurnDTO.fromJson(Map<String, dynamic> json) {
    final scoreJson = SessionDTO._asMap(json['score']);
    return TurnDTO(
      index: SessionDTO._intOrNull(json['index']) ?? 0,
      role: SessionDTO._string(json['role']) ?? 'ai',
      text: SessionDTO._string(json['text']) ?? '',
      score: scoreJson == null ? null : TurnScoreDTO.fromJson(scoreJson),
      mispronouncedWords: _stringList(json['mispronouncedWords'] ?? json['mispronounced_words']),
      modelAudioUrl: SessionDTO._string(json['modelAudioUrl'] ?? json['model_audio_url']),
      userAudioUrl: SessionDTO._string(json['userAudioUrl'] ?? json['user_audio_url']),
      speechAnalysis: _speechAnalysis(json['speechAnalysis'] ?? json['speech_analysis']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'role': role,
      'text': text,
      'score': score?.toJson(),
      'mispronouncedWords': mispronouncedWords,
      'modelAudioUrl': modelAudioUrl,
      'userAudioUrl': userAudioUrl,
      'speechAnalysis': speechAnalysis?.toJson(),
    };
  }

  static List<String>? _stringList(Object? value) {
    if (value is List) {
      final items = value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
      return items.isEmpty ? null : items;
    }
    return null;
  }

  static TurnSpeechAnalysisDTO? _speechAnalysis(Object? value) {
    if (value is Map<String, dynamic>) {
      return TurnSpeechAnalysisDTO.fromJson(value);
    }
    return null;
  }

  bool get isUser => role == 'user';

  bool get isComplete {
    if (!isUser) return true;
    return (userAudioUrl?.isNotEmpty ?? false) || score != null;
  }
}

class TurnScoreDTO {
  final double confidence;
  final double fluency;
  final double hesitation;

  const TurnScoreDTO({
    required this.confidence,
    required this.fluency,
    required this.hesitation,
  });

  factory TurnScoreDTO.fromJson(Map<String, dynamic> json) {
    return TurnScoreDTO(
      confidence: SessionDTO._doubleOrNull(json['confidence']) ?? 0,
      fluency: SessionDTO._doubleOrNull(json['fluency']) ?? 0,
      hesitation: SessionDTO._doubleOrNull(json['hesitation']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'fluency': fluency,
      'hesitation': hesitation,
    };
  }
}

class TurnSpeechAnalysisDTO {
  final String? expectedText;
  final String? asrText;
  final AlignmentSummaryDTO? alignmentSummary;

  const TurnSpeechAnalysisDTO({
    this.expectedText,
    this.asrText,
    this.alignmentSummary,
  });

  factory TurnSpeechAnalysisDTO.fromJson(Map<String, dynamic> json) {
    return TurnSpeechAnalysisDTO(
      expectedText: SessionDTO._string(json['expectedText'] ?? json['expected_text']),
      asrText: SessionDTO._string(json['asrText'] ?? json['asr_text']),
      alignmentSummary: _alignmentSummary(json['alignmentSummary'] ?? json['alignment_summary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expectedText': expectedText,
      'asrText': asrText,
      'alignmentSummary': alignmentSummary?.toJson(),
    };
  }

  static AlignmentSummaryDTO? _alignmentSummary(Object? value) {
    if (value is Map<String, dynamic>) {
      return AlignmentSummaryDTO.fromJson(value);
    }
    return null;
  }
}

class AlignmentSummaryDTO {
  final double? wer;

  const AlignmentSummaryDTO({this.wer});

  factory AlignmentSummaryDTO.fromJson(Map<String, dynamic> json) {
    return AlignmentSummaryDTO(
      wer: SessionDTO._doubleOrNull(json['wer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wer': wer,
    };
  }
}
