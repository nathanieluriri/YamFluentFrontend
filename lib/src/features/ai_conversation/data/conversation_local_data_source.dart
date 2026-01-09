import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ConversationProgress {
  final String? lastSessionId;
  final int? startedAtLocalEpochMs;
  final int? visibleTurnIndex;
  final bool? completed;

  const ConversationProgress({
    this.lastSessionId,
    this.startedAtLocalEpochMs,
    this.visibleTurnIndex,
    this.completed,
  });
}

abstract class ConversationLocalDataSource {
  Future<ConversationProgress> getProgress();
  Future<void> saveProgress({
    String? lastSessionId,
    int? startedAtLocalEpochMs,
    int? visibleTurnIndex,
    bool? completed,
  });
  Future<void> clearProgress();
}

class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  static const boxName = 'conversationProgress';
  static const keyLastSessionId = 'lastSessionId';
  static const keyStartedAt = 'startedAtLocalEpochMs';
  static const keyVisibleTurnIndex = 'visibleTurnIndex';
  static const keyCompleted = 'completed';

  @override
  Future<ConversationProgress> getProgress() async {
    final box = await Hive.openBox<dynamic>(boxName);
    return ConversationProgress(
      lastSessionId: box.get(keyLastSessionId) as String?,
      startedAtLocalEpochMs: box.get(keyStartedAt) as int?,
      visibleTurnIndex: box.get(keyVisibleTurnIndex) as int?,
      completed: box.get(keyCompleted) as bool?,
    );
  }

  @override
  Future<void> saveProgress({
    String? lastSessionId,
    int? startedAtLocalEpochMs,
    int? visibleTurnIndex,
    bool? completed,
  }) async {
    final box = await Hive.openBox<dynamic>(boxName);
    if (lastSessionId != null) {
      await box.put(keyLastSessionId, lastSessionId);
    }
    if (startedAtLocalEpochMs != null) {
      await box.put(keyStartedAt, startedAtLocalEpochMs);
    }
    if (visibleTurnIndex != null) {
      await box.put(keyVisibleTurnIndex, visibleTurnIndex);
    }
    if (completed != null) {
      await box.put(keyCompleted, completed);
    }
  }

  @override
  Future<void> clearProgress() async {
    final box = await Hive.openBox<dynamic>(boxName);
    await box.delete(keyLastSessionId);
    await box.delete(keyStartedAt);
    await box.delete(keyVisibleTurnIndex);
    await box.delete(keyCompleted);
  }
}

final conversationLocalDataSourceProvider =
    Provider<ConversationLocalDataSource>((ref) {
  return ConversationLocalDataSourceImpl();
});
