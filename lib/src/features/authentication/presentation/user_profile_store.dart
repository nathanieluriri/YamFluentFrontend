import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart';

class UserProfileState {
  final User? user;
  final DateTime? lastSuccessfulFetch;

  const UserProfileState({
    this.user,
    this.lastSuccessfulFetch,
  });

  UserProfileState copyWith({
    User? user,
    DateTime? lastSuccessfulFetch,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      lastSuccessfulFetch: lastSuccessfulFetch ?? this.lastSuccessfulFetch,
    );
  }
}

class UserProfileStore extends StateNotifier<UserProfileState> {
  UserProfileStore() : super(const UserProfileState());

  void setUser(User user) {
    state = UserProfileState(
      user: user,
      lastSuccessfulFetch: DateTime.now(),
    );
  }

  void clear() {
    state = const UserProfileState();
  }
}

final userProfileStoreProvider =
    StateNotifierProvider<UserProfileStore, UserProfileState>((ref) {
  return UserProfileStore();
});
