import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_error_classifier.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/auth_failure_notifier.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/failure.dart';
import '../../../../ui/widgets/common/app_snackbar.dart';
import '../data/auth_local_data_source.dart';
import '../domain/login_use_case.dart';
import '../domain/user.dart';
import '../data/auth_repository_impl.dart';
import 'user_profile_store.dart';


final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final authBootstrapProvider = StateProvider<bool>((ref) => false);


class AuthController extends AsyncNotifier<User?> {
  bool _hasLoadedSession = false;
  bool _isBootstrapped = false;
  bool _isBootstrapping = false;

  bool get isBootstrapped => _isBootstrapped;

  @override
  FutureOr<User?> build() {
    ref.listen<int?>(authFailureProvider, (previous, next) {
      if (next != null && next != previous) {
        _forceLogout();
        ref.read(authFailureProvider.notifier).clear();
      }
    });
    ref.listen<UserProfileState>(userProfileStoreProvider, (previous, next) {
      if (!_isBootstrapping && next.user != null) {
        state = AsyncValue.data(next.user);
      }
    });
    return null; 
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(email, password);

    await result.fold(
      (failure) async =>
          state = AsyncValue.error(failure as Object, StackTrace.current),
      (user) async {
        await _setAuthenticatedUser(user);
        final refreshed = await _fetchCurrentUserOrFallback(
          user,
          preferFallbackOnboarding: true,
        );
        await _setAuthenticatedUser(refreshed);
        _markBootstrapped();
      },
    );
  }

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signUp(name, email, password);
    await result.fold(
      (failure) async =>
          state = AsyncValue.error(failure as Object, StackTrace.current),
      (user) async {
        await _setAuthenticatedUser(user);
        final refreshed = await _fetchCurrentUserOrFallback(
          user,
          preferFallbackOnboarding: true,
        );
        await _setAuthenticatedUser(refreshed);
        _markBootstrapped();
      },
    );
  }

  Future<String> requestPasswordReset(String email) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.requestPasswordReset(email);
    return result.fold(
      (failure) => throw failure as Object, 
      (detail) => detail,
    );
  }

  Future<String> confirmPasswordReset(
    String resetToken,
    String password,
  ) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.confirmPasswordReset(resetToken, password);
    return result.fold(
      (failure) => throw failure as Object, 
      (detail) => detail,
    );
  }

  Future<void> setTokensFromDeepLink(
    String accessToken,
    String refreshToken,
  ) async {
    state = const AsyncValue.loading();
    try {
      final tokenStore = ref.read(authLocalDataSourceProvider);
      await tokenStore.saveTokens(accessToken, refreshToken);

      _setAuthHeader(accessToken);

      final repo = ref.read(authRepositoryProvider);
      final result = await repo.getCurrentUser();
      result.fold(
        (failure) => _handleProfileFetchFailure(failure),
        (user) => _setAuthenticatedUser(user),
      );
      _markBootstrapped();
    } catch (e, stackTrace) {
      logger.e(
        'Failed to set tokens from deep link',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
      _markBootstrapped();
    }
  }

  Future<void> signInWithGoogle({bool silent = false}) async {
    if (!silent) {
      state = const AsyncValue.loading();
    }
    try {
      final uri = Uri.parse(
        'https://api-yamfluent.uriri.com.ng/v1/users/mobile/google/auth',
      );
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (silent) {
          throw 'Google sign-in unavailable.';
        }
        state = AsyncValue.error(
          'Google sign-in unavailable.',
          StackTrace.current,
        );
        return;
      }
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (silent) {
          throw 'Could not open Google sign-in.';
        }
        state = AsyncValue.error(
          'Could not open Google sign-in.',
          StackTrace.current,
        );
      } else if (!silent) {
        state = AsyncValue.data(state.value);
      }
    } catch (e, stackTrace) {
      if (silent) {
        rethrow;
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadSessionOnStart() async {
    if (_hasLoadedSession) {
      return;
    }
    _hasLoadedSession = true;
    _isBootstrapping = true;
    ref.read(userProfileStoreProvider.notifier).clear();
    state = const AsyncValue.loading();

    try {
      final tokenStore = ref.read(authLocalDataSourceProvider);
      final accessToken = await tokenStore.getAccessToken();
      final refreshToken = await tokenStore.getRefreshToken();
      if (accessToken == null || refreshToken == null) {
        state = const AsyncValue.data(null);
        _markBootstrapped();
        return;
      }

      _setAuthHeader(accessToken);
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.getCurrentUser();
      await result.fold(
        (failure) async => _handleProfileFetchFailure(failure),
        (user) async => _setAuthenticatedUser(user),
      );
      _markBootstrapped();
    } catch (e, stackTrace) {
      logger.e(
        'Failed to load session on start',
        error: e,
        stackTrace: stackTrace,
      );
      state = const AsyncValue.data(null);
      _markBootstrapped();
    }
  }

  Future<void> logout() async {
    try {
      final tokenStore = ref.read(authLocalDataSourceProvider);
      final accessToken = await tokenStore.getAccessToken();
      if (accessToken != null) {
        _setAuthHeader(accessToken);
      }
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.logout();
      result.fold(
        (failure) => logger.w('Logout request failed', error: failure),
        (_) {},
      );
      await tokenStore.clearTokens();
    } catch (e, stackTrace) {
      logger.w('Logout failed', error: e, stackTrace: stackTrace);
    } finally {
      _clearAuthHeader();
      state = const AsyncValue.data(null);
      ref.read(userProfileStoreProvider.notifier).clear();
      _markBootstrapped();
    }
  }

  Future<void> logoutLocalOnly() async {
    await _forceLogout();
  }

  Future<void> deleteAccount() async {
    try {
      final tokenStore = ref.read(authLocalDataSourceProvider);
      final accessToken = await tokenStore.getAccessToken();
      if (accessToken != null) {
        _setAuthHeader(accessToken);
      }
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.deleteAccount();
      result.fold(
        (failure) => logger.w('Delete account request failed', error: failure),
        (_) {},
      );
      await tokenStore.clearTokens();
    } catch (e, stackTrace) {
      logger.w('Delete account failed', error: e, stackTrace: stackTrace);
    } finally {
      _clearAuthHeader();
      state = const AsyncValue.data(null);
      ref.read(userProfileStoreProvider.notifier).clear();
      _markBootstrapped();
    }
  }

  Future<void> refreshCurrentUser({bool silent = false}) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getCurrentUser();
    result.fold(
      (failure) => _handleProfileFetchFailure(failure, silent: silent),
      (user) => _setAuthenticatedUser(_mergeTokens(user, state.value)),
    );
  }

  Future<void> _persistTokens(User user) async {
    final accessToken = user.accessToken;
    final refreshToken = user.refreshToken;
    if (accessToken == null) {
      return;
    }
    final tokenStore = ref.read(authLocalDataSourceProvider);
    final storedRefreshToken =
        refreshToken ?? await tokenStore.getRefreshToken();
    if (storedRefreshToken != null) {
      await tokenStore.saveTokens(accessToken, storedRefreshToken);
    }
    _setAuthHeader(accessToken);
  }

  Future<void> _setAuthenticatedUser(User user) async {
    await _persistTokens(user);
    ref.read(userProfileStoreProvider.notifier).setUser(user);
    state = AsyncValue.data(user);
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final current = state.value ?? ref.read(userProfileStoreProvider).user;
    if (current == null) {
      return;
    }
    final updated = User(
      id: current.id,
      email: current.email,
      name: current.name,
      photoUrl: current.photoUrl,
      accessToken: current.accessToken,
      refreshToken: current.refreshToken,
      onboardingCompleted: value,
    );
    await _setAuthenticatedUser(updated);
  }

  Future<User> _fetchCurrentUserOrFallback(
    User fallback, {
    bool preferFallbackOnboarding = false,
  }) async {
    if (preferFallbackOnboarding && fallback.onboardingCompleted == false) {
      return fallback;
    }
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getCurrentUser();
    return result.fold((failure) {
      logger.w('Failed to refresh user after auth', error: failure);
      return fallback;
    }, (user) => _mergeTokens(user, fallback));
  }

  User _mergeTokens(User user, User? fallback) {
    if (fallback == null) {
      return user;
    }
    return User(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      accessToken: user.accessToken ?? fallback.accessToken,
      refreshToken: user.refreshToken ?? fallback.refreshToken,
      onboardingCompleted: user.onboardingCompleted,
    );
  }

  Future<void> _handleProfileFetchFailure(
    Failure failure, {
    bool silent = false,
  }) async {
    final cachedUser = ref.read(userProfileStoreProvider).user ?? state.value;
    final statusCode = failure is ServerFailure ? failure.statusCode : null;
    if (ApiErrorClassifier.isAuthStatus(statusCode)) {
      await _forceLogout();
      return;
    }

    if (!silent) {
      final message = _messageForFailure(failure);
      scaffoldMessengerKey.currentState?.showSnackBar(
        buildAppSnackBar(message),
      );
    } else {
      logger.w('Profile refresh failed', error: failure);
    }

    if (cachedUser != null) {
      state = AsyncValue.data(cachedUser);
    } else {
      state = const AsyncValue.data(null);
    }
  }

  String _messageForFailure(Failure failure) {
    if (failure is ConnectionFailure) {
      return 'You are offline. Please check your connection.';
    }
    if (failure is ServerFailure) {
      final statusCode = failure.statusCode ?? 0;
      if (statusCode >= 500) {
        return 'Server error, try again.';
      }
      if (statusCode == 429) {
        return 'Too many requests. Please try again.';
      }
      if (ApiErrorClassifier.isAuthStatus(statusCode)) {
        return 'Session expired. Please sign in again.';
      }
    }
    return failure.message;
  }

  Future<void> _forceLogout() async {
    final tokenStore = ref.read(authLocalDataSourceProvider);
    await tokenStore.clearTokens();
    _clearAuthHeader();
    ref.read(userProfileStoreProvider.notifier).clear();
    state = const AsyncValue.data(null);
    _markBootstrapped();
  }

  void _markBootstrapped() {
    if (_isBootstrapped) {
      return;
    }
    _isBootstrapped = true;
    _isBootstrapping = false;
    ref.read(authBootstrapProvider.notifier).state = true;
  }

  void _setAuthHeader(String accessToken) {
    final dio = ref.read(dioProvider);
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  void _clearAuthHeader() {
    final dio = ref.read(dioProvider);
    dio.options.headers.remove('Authorization');
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});
