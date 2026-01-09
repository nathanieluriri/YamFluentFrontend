import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yam_fluent/src/features/ai_conversation/data/conversation_repository_impl.dart';

import '../../../core/utils/logger.dart';
import '../data/conversation_local_data_source.dart';
import '../data/session_dto.dart';
import '../domain/conversation_repository.dart';
import '../domain/start_session_use_case.dart';
import 'services/audio_player_service.dart';
import 'services/audio_recorder_service.dart';

class ConversationState {
  final SessionDTO? session;
  final SessionDTO? resumeCandidate;
  final String? scenarioId;
  final int visibleTurnIndex;
  final int? startedAtLocalEpochMs;
  final bool isLoading;
  final bool isRecording;
  final bool isUploading;
  final bool promptResume;
  final int? currentPlayingTurnIndex;
  final double recordingAmplitude;
  final String? errorMessage;
  final Map<int, DateTime> revealTimes;

  const ConversationState({
    this.session,
    this.resumeCandidate,
    this.scenarioId,
    this.visibleTurnIndex = -1,
    this.startedAtLocalEpochMs,
    this.isLoading = false,
    this.isRecording = false,
    this.isUploading = false,
    this.promptResume = false,
    this.currentPlayingTurnIndex,
    this.recordingAmplitude = 0,
    this.errorMessage,
    this.revealTimes = const {},
  });

  ConversationState copyWith({
    SessionDTO? session,
    SessionDTO? resumeCandidate,
    String? scenarioId,
    int? visibleTurnIndex,
    int? startedAtLocalEpochMs,
    bool? isLoading,
    bool? isRecording,
    bool? isUploading,
    bool? promptResume,
    int? currentPlayingTurnIndex,
    double? recordingAmplitude,
    String? errorMessage,
    Map<int, DateTime>? revealTimes,
  }) {
    return ConversationState(
      session: session ?? this.session,
      resumeCandidate: resumeCandidate ?? this.resumeCandidate,
      scenarioId: scenarioId ?? this.scenarioId,
      visibleTurnIndex: visibleTurnIndex ?? this.visibleTurnIndex,
      startedAtLocalEpochMs:
          startedAtLocalEpochMs ?? this.startedAtLocalEpochMs,
      isLoading: isLoading ?? this.isLoading,
      isRecording: isRecording ?? this.isRecording,
      isUploading: isUploading ?? this.isUploading,
      promptResume: promptResume ?? this.promptResume,
      currentPlayingTurnIndex:
          currentPlayingTurnIndex ?? this.currentPlayingTurnIndex,
      recordingAmplitude: recordingAmplitude ?? this.recordingAmplitude,
      errorMessage: errorMessage,
      revealTimes: revealTimes ?? this.revealTimes,
    );
  }
}

// Providers
final startSessionUseCaseProvider = Provider<StartSessionUseCase>((ref) {
  return StartSessionUseCase(ref.watch(conversationRepositoryProvider));
});

final conversationControllerProvider =
    StateNotifierProvider<ConversationController, ConversationState>((ref) {
      return ConversationController(
        ref.watch(startSessionUseCaseProvider),
        ref.watch(conversationRepositoryProvider),
        ref.watch(conversationLocalDataSourceProvider),
        ref.watch(audioPlayerServiceProvider),
        ref.watch(audioRecorderServiceProvider),
      );
    });

class ConversationController extends StateNotifier<ConversationState> {
  final StartSessionUseCase _startSessionUseCase;
  final ConversationRepository _repository;
  final ConversationLocalDataSource _localDataSource;
  final AudioPlayerService _audioPlayerService;
  final AudioRecorderService _audioRecorderService;

  StreamSubscription<double>? _amplitudeSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  ConversationController(
    this._startSessionUseCase,
    this._repository,
    this._localDataSource,
    this._audioPlayerService,
    this._audioRecorderService,
  ) : super(const ConversationState()) {
    _playerStateSub = _audioPlayerService.playerStateStream.listen((
      playerState,
    ) {
      if (!playerState.playing ||
          playerState.processingState == ProcessingState.completed) {
        state = state.copyWith(currentPlayingTurnIndex: null);
      }
    });
  }

  Future<void> initialize(String scenarioId, {String? sessionId}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, scenarioId: scenarioId);
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      final result = await _repository.getSessionById(sessionId);
      await result.match(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.toString(),
          );
        },
        (session) async {
          final startedAt = DateTime.now().millisecondsSinceEpoch;
          final visibleIndex = _computeVisibleTurnIndex(session);
          state = state.copyWith(
            session: session,
            resumeCandidate: null,
            visibleTurnIndex: visibleIndex,
            startedAtLocalEpochMs: startedAt,
            isLoading: false,
            errorMessage: null,
            revealTimes: _seedRevealTimes(
              state.revealTimes,
              session,
              visibleIndex,
            ),
          );
          await _localDataSource.saveProgress(
            lastSessionId: session.id,
            startedAtLocalEpochMs: startedAt,
            visibleTurnIndex: visibleIndex,
            completed: session.completed,
          );
        },
      );
      return;
    }
    final progress = await _localDataSource.getProgress();
    final lastSessionId = progress.lastSessionId;
    if (lastSessionId != null && lastSessionId.trim().isNotEmpty) {
      final result = await _repository.getSessionById(lastSessionId);
      await result.match(
        (failure) async {
          logger.e('Failed to fetch session: $failure');
        },
        (session) async {
          if (!(session.completed)) {
            final startedAt =
                progress.startedAtLocalEpochMs ??
                DateTime.now().millisecondsSinceEpoch;
            final visibleIndex = _computeVisibleTurnIndex(session);
            state = state.copyWith(
              isLoading: false,
              promptResume: true,
              resumeCandidate: session,
              startedAtLocalEpochMs: startedAt,
              visibleTurnIndex: visibleIndex,
              revealTimes: _seedRevealTimes(
                state.revealTimes,
                session,
                visibleIndex,
              ),
            );
            return;
          }
        },
      );
    }
    if (state.promptResume) {
      return;
    }
    await startNewSession(scenarioId);
  }

  Future<void> startNewSession(String scenarioId) async {
    state = state.copyWith(
      isLoading: true,
      promptResume: false,
      errorMessage: null,
    );
    final result = await _startSessionUseCase(scenarioId);
    await result.match(
      (failure) async {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.toString(),
        );
      },
      (session) async {
        final startedAt = DateTime.now().millisecondsSinceEpoch;
        final visibleIndex = _computeVisibleTurnIndex(session);
        state = state.copyWith(
          session: session,
          resumeCandidate: null,
          visibleTurnIndex: visibleIndex,
          startedAtLocalEpochMs: startedAt,
          isLoading: false,
          errorMessage: null,
          revealTimes: _seedRevealTimes(
            state.revealTimes,
            session,
            visibleIndex,
          ),
        );
        await _localDataSource.saveProgress(
          lastSessionId: session.id,
          startedAtLocalEpochMs: startedAt,
          visibleTurnIndex: visibleIndex,
          completed: session.completed,
        );
      },
    );
  }

  Future<void> continueSession() async {
    final session = state.resumeCandidate;
    if (session == null) return;
    final startedAt =
        state.startedAtLocalEpochMs ?? DateTime.now().millisecondsSinceEpoch;
    final visibleIndex = _computeVisibleTurnIndex(session);
    state = state.copyWith(
      session: session,
      resumeCandidate: null,
      promptResume: false,
      visibleTurnIndex: visibleIndex,
      startedAtLocalEpochMs: startedAt,
      revealTimes: _seedRevealTimes(state.revealTimes, session, visibleIndex),
    );
    await _localDataSource.saveProgress(
      lastSessionId: session.id,
      startedAtLocalEpochMs: startedAt,
      visibleTurnIndex: visibleIndex,
      completed: session.completed,
    );
  }

  Future<void> discardAndStartNew() async {
    await _localDataSource.clearProgress();
    final scenarioId = state.scenarioId ?? '';
    await startNewSession(scenarioId);
  }

  Future<void> refreshSession() async {
    final session = state.session;
    if (session == null) return;
    final result = await _repository.getSessionById(session.id);
    await result.match(
      (failure) async {
        state = state.copyWith(errorMessage: failure.toString());
      },
      (updated) async {
        final visibleIndex = _computeVisibleTurnIndex(updated);
        state = state.copyWith(
          session: updated,
          visibleTurnIndex: visibleIndex,
          revealTimes: _seedRevealTimes(
            state.revealTimes,
            updated,
            visibleIndex,
          ),
        );
        await _localDataSource.saveProgress(
          lastSessionId: updated.id,
          visibleTurnIndex: visibleIndex,
          completed: updated.completed,
        );
      },
    );
  }

  Future<void> togglePlayback(int turnIndex, {required String url}) async {
    try {
      final isPlaying = await _audioPlayerService.toggleWithAuth(url);
      state = state.copyWith(
        currentPlayingTurnIndex: isPlaying ? turnIndex : null,
      );
    } catch (e) {
      state = state.copyWith(
        currentPlayingTurnIndex: null,
        errorMessage: 'Failed to play audio.',
      );
    }
  }

  int? nextUserTurnIndex() {
    final session = state.session;
    if (session == null) return null;
    final turns = _sortedTurns(session);
    final nextIndex = state.visibleTurnIndex + 1;
    final nextTurn = turns.firstWhere(
      (turn) => turn.index == nextIndex,
      orElse: () => TurnDTO(index: -1, role: '', text: ''),
    );
    if (nextTurn.index == -1 || !nextTurn.isUser) {
      return null;
    }
    return nextTurn.index;
  }

  Future<void> startRecording() async {
    final session = state.session;
    if (session == null || state.isRecording || state.isUploading) return;
    final turnIndex = nextUserTurnIndex();
    if (turnIndex == null) return;
    final baseName = _recordingBaseName(session.id, turnIndex);
    final startedPath = await _audioRecorderService.startRecording(baseName);
    if (startedPath == null) {
      state = state.copyWith(errorMessage: 'Microphone permission denied.');
      return;
    }
    _amplitudeSub?.cancel();
    _amplitudeSub = _audioRecorderService.amplitudeStream.listen((amplitude) {
      state = state.copyWith(recordingAmplitude: amplitude);
    });
    state = state.copyWith(isRecording: true, errorMessage: null);
  }

  Future<void> stopRecordingAndUpload() async {
    final session = state.session;
    if (session == null || !state.isRecording) return;
    final turnIndex = nextUserTurnIndex();
    if (turnIndex == null) return;
    final baseName = _recordingBaseName(session.id, turnIndex);
    state = state.copyWith(isRecording: false, isUploading: true);
    final mp3Path = await _audioRecorderService.stopRecordingAndConvert(
      baseName,
    );
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    if (mp3Path == null) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Failed to prepare audio upload.',
      );
      return;
    }
    final result = await _repository.uploadTurnAudio(
      session.id,
      turnIndex,
      mp3Path,
    );
    await result.match(
      (failure) async {
        state = state.copyWith(
          isUploading: false,
          errorMessage: failure.toString(),
        );
      },
      (updated) async {
        final visibleIndex = _computeVisibleTurnIndex(updated);
        state = state.copyWith(
          session: updated,
          visibleTurnIndex: visibleIndex,
          isUploading: false,
          errorMessage: null,
          revealTimes: _seedRevealTimes(
            state.revealTimes,
            updated,
            visibleIndex,
          ),
        );
        await _localDataSource.saveProgress(
          lastSessionId: updated.id,
          visibleTurnIndex: visibleIndex,
          completed: updated.completed,
        );
      },
    );
  }

  Future<void> cancelRecording() async {
    if (!state.isRecording) return;
    await _audioRecorderService.cancelRecording();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    state = state.copyWith(isRecording: false, recordingAmplitude: 0);
  }

  Future<void> markAutoClosed() async {
    final session = state.session;
    if (session == null) return;
    await _localDataSource.saveProgress(
      lastSessionId: session.id,
      visibleTurnIndex: state.visibleTurnIndex,
      completed: session.completed,
    );
  }

  int _computeVisibleTurnIndex(SessionDTO session) {
    final turns = _sortedTurns(session);
    var visible = -1;
    for (final turn in turns) {
      if (turn.role == 'ai') {
        visible = turn.index;
        continue;
      }
      if (turn.isComplete) {
        visible = turn.index;
      } else {
        break;
      }
    }
    return visible;
  }

  List<TurnDTO> _sortedTurns(SessionDTO session) {
    final turns = session.script?.turns ?? const <TurnDTO>[];
    final sorted = List<TurnDTO>.from(turns)
      ..sort((a, b) => a.index.compareTo(b.index));
    return sorted;
  }

  Map<int, DateTime> _seedRevealTimes(
    Map<int, DateTime> current,
    SessionDTO session,
    int visibleIndex,
  ) {
    final now = DateTime.now();
    final updated = Map<int, DateTime>.from(current);
    for (final turn in _sortedTurns(session)) {
      if (turn.index <= visibleIndex && !updated.containsKey(turn.index)) {
        updated[turn.index] = now;
      }
    }
    return updated;
  }

  String _recordingBaseName(String sessionId, int turnIndex) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$sessionId-$turnIndex-$timestamp';
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _playerStateSub?.cancel();
    unawaited(_audioRecorderService.cancelRecording());
    super.dispose();
  }
}
