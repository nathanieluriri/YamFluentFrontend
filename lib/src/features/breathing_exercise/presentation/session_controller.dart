import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sessions_api.dart';

class SessionState {
  final AsyncValue<String?> status;

  const SessionState({required this.status});

  factory SessionState.initial() =>
      const SessionState(status: AsyncValue.data(null));

  SessionState copyWith({AsyncValue<String?>? status}) {
    return SessionState(status: status ?? this.status);
  }
}

class SessionController extends StateNotifier<SessionState> {
  final SessionsApi _api;

  SessionController(this._api) : super(SessionState.initial());

  Future<void> startSessionCreation(String scenario) async {
    state = state.copyWith(status: const AsyncValue.loading());

    try {
      final sessionId = await _api.createSession(scenario);
      if (mounted) {
        state = state.copyWith(status: AsyncValue.data(sessionId));
      }
    } catch (e, st) {
      if (mounted) {
        state = state.copyWith(status: AsyncValue.error(e, st));
      }
    }
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
      return SessionController(ref.watch(sessionsApiProvider));
    });
