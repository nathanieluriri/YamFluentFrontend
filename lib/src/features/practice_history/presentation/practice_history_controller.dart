import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../ai_conversation/data/session_dto.dart';
import '../../ai_conversation/data/sessions_api_client.dart';
import '../data/practice_history_api.dart';
import '../domain/practice_session_summary.dart';

enum PracticeHistoryFilter { all, completed, incomplete }

class PracticeHistoryState {
  final AsyncValue<List<PracticeSessionSummary>> sessions;
  final PracticeHistoryFilter filter;
  final Map<String, SessionDTO> sessionDetails;
  final bool isDetailLoading;

  const PracticeHistoryState({
    required this.sessions,
    this.filter = PracticeHistoryFilter.all,
    this.sessionDetails = const {},
    this.isDetailLoading = false,
  });

  PracticeHistoryState copyWith({
    AsyncValue<List<PracticeSessionSummary>>? sessions,
    PracticeHistoryFilter? filter,
    Map<String, SessionDTO>? sessionDetails,
    bool? isDetailLoading,
  }) {
    return PracticeHistoryState(
      sessions: sessions ?? this.sessions,
      filter: filter ?? this.filter,
      sessionDetails: sessionDetails ?? this.sessionDetails,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
    );
  }
}

class PracticeHistoryController extends Notifier<PracticeHistoryState> {
  late final PracticeHistoryApi _api;
  late final SessionsApiClient _sessionsApi;
  bool _hasLoaded = false;
  bool _initialized = false;

  @override
  PracticeHistoryState build() {
    if (!_initialized) {
      _api = ref.read(practiceHistoryApiProvider);
      _sessionsApi = ref.read(sessionsApiClientProvider);
      _initialized = true;
    }
    final initial = const PracticeHistoryState(
      sessions: AsyncValue.loading(),
    );
    Future.microtask(_loadSessions);
    return initial;
  }

  Future<void> refresh() async {
    _hasLoaded = false;
    await _loadSessions();
  }

  Future<void> setFilter(PracticeHistoryFilter filter) async {
    if (filter == state.filter) return;
    state = state.copyWith(filter: filter);
    if (filter != PracticeHistoryFilter.all) {
      await _ensureSessionDetails();
    }
  }

  SessionDTO? detailFor(String sessionId) {
    return state.sessionDetails[sessionId];
  }

  Future<SessionDTO?> fetchSessionDetail(String sessionId) async {
    final cached = state.sessionDetails[sessionId];
    if (cached != null) {
      return cached;
    }
    try {
      final detail = await _sessionsApi.getSessionById(sessionId);
      _cacheDetail(detail);
      return detail;
    } catch (e, stackTrace) {
      logger.e('Failed to fetch session detail: $sessionId',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> _loadSessions() async {
    if (_hasLoaded && !state.sessions.isRefreshing) {
      return;
    }
    state = state.copyWith(
      sessions: const AsyncValue<List<PracticeSessionSummary>>.loading()
          .copyWithPrevious(state.sessions),
    );
    try {
      final sessions = await _api.listSessions();
      _hasLoaded = true;
      state = state.copyWith(sessions: AsyncValue.data(sessions));
      if (state.filter != PracticeHistoryFilter.all) {
        await _ensureSessionDetails();
      }
    } catch (e, stackTrace) {
      logger.e('Failed to load practice history',
          error: e, stackTrace: stackTrace);
      state = state.copyWith(
        sessions: AsyncValue.error(e, stackTrace),
      );
    }
  }

  Future<void> _ensureSessionDetails() async {
    final sessions = state.sessions.valueOrNull ?? const <PracticeSessionSummary>[];
    final missing = sessions
        .where((session) => !state.sessionDetails.containsKey(session.id))
        .map((session) => session.id)
        .toList();
    if (missing.isEmpty) return;
    state = state.copyWith(isDetailLoading: true);
    for (final id in missing) {
      try {
        final detail = await _sessionsApi.getSessionById(id);
        _cacheDetail(detail);
      } catch (e, stackTrace) {
        logger.e('Failed to fetch session detail: $id',
            error: e, stackTrace: stackTrace);
      }
    }
    state = state.copyWith(isDetailLoading: false);
  }

  void _cacheDetail(SessionDTO detail) {
    state = state.copyWith(
      sessionDetails: {
        ...state.sessionDetails,
        detail.id: detail,
      },
    );
  }
}

final practiceHistoryControllerProvider =
    NotifierProvider<PracticeHistoryController, PracticeHistoryState>(
  PracticeHistoryController.new,
);
