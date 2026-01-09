import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthFailureNotifier extends StateNotifier<int?> {
  AuthFailureNotifier() : super(null);

  void notify(int statusCode) {
    state = statusCode;
  }

  void clear() {
    state = null;
  }
}

final authFailureProvider =
    StateNotifierProvider<AuthFailureNotifier, int?>((ref) {
  return AuthFailureNotifier();
});
