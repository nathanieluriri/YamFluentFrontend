import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalLoadingState {
  final int count;
  final String? message;

  const GlobalLoadingState({
    required this.count,
    this.message,
  });

  bool get isLoading => count > 0;

  GlobalLoadingState copyWith({
    int? count,
    String? message,
  }) {
    return GlobalLoadingState(
      count: count ?? this.count,
      message: message ?? this.message,
    );
  }
}

class GlobalLoadingController extends StateNotifier<GlobalLoadingState> {
  GlobalLoadingController() : super(const GlobalLoadingState(count: 0));

  void show({String? message}) {
    state = state.copyWith(
      count: state.count + 1,
      message: message ?? state.message,
    );
  }

  void hide() {
    final nextCount = state.count - 1;
    state = state.copyWith(
      count: nextCount < 0 ? 0 : nextCount,
      message: nextCount <= 0 ? null : state.message,
    );
  }
}

final globalLoadingControllerProvider =
    StateNotifierProvider<GlobalLoadingController, GlobalLoadingState>((ref) {
  return GlobalLoadingController();
});
