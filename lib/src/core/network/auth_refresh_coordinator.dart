import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/data/auth_local_data_source.dart';
import '../../features/authentication/data/user_dto.dart';
import 'api_response.dart';
import '../utils/logger.dart';

class AuthRefreshCoordinator {
  final Dio _dio;
  final AuthLocalDataSource _authLocalDataSource;
  Future<String?>? _inFlight;

  AuthRefreshCoordinator(this._dio, this._authLocalDataSource);

  Future<String?> refreshAccessToken() {
    if (_inFlight != null) {
      return _inFlight!;
    }

    final completer = Completer<String?>();
    _inFlight = completer.future;

    _performRefresh()
        .then(completer.complete)
        .catchError((error, stackTrace) {
          logger.e(
            '[AuthRefreshCoordinator] refresh failed',
            error: error,
            stackTrace: stackTrace,
          );
          completer.complete(null);
        })
        .whenComplete(() => _inFlight = null);

    return _inFlight!;
  }

  Future<String?> _performRefresh() async {
    final accessToken = await _authLocalDataSource.getAccessToken();
    final refreshToken = await _authLocalDataSource.getRefreshToken();
    if (accessToken == null || refreshToken == null) {
      logger.w('[AuthRefreshCoordinator] missing tokens for refresh');
      return null;
    }

    logger.i('[AuthRefreshCoordinator] refresh start');
    try {
      final response = await _dio.post(
        '/v1/users/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      logger.i('[AuthRefreshCoordinator] refresh status=${response.statusCode}');

      final api = APIResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserDTO.fromJson(json is Map<String, dynamic> ? json : <String, dynamic>{}),
      );
      if (api.data == null) {
        logger.w('[AuthRefreshCoordinator] refresh response missing data');
        return null;
      }

      final newAccessToken = api.data!.accessToken;
      final newRefreshToken = api.data!.refreshToken ?? refreshToken;
      if (newAccessToken == null) {
        logger.w('[AuthRefreshCoordinator] refresh response missing tokens');
        return null;
      }

      await _authLocalDataSource.saveTokens(newAccessToken, newRefreshToken);
      return newAccessToken;
    } catch (e, stackTrace) {
      logger.e(
        '[AuthRefreshCoordinator] refresh error',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}

final authRefreshDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api-yamfluent.uriri.com.ng',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
});

final authRefreshCoordinatorProvider = Provider<AuthRefreshCoordinator>((ref) {
  return AuthRefreshCoordinator(
    ref.watch(authRefreshDioProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});
