import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/data/auth_local_data_source.dart';
import '../../features/authentication/presentation/auth_controller.dart';
import '../router/app_router.dart';
import '../ui/global_loading_controller.dart';
import '../utils/logger.dart';
import 'auth_refresh_coordinator.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final Dio _dio;
  final AuthRefreshCoordinator _coordinator;

  AuthInterceptor(this._ref, this._dio, this._coordinator);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }
    if (options.extra['preserveAuthHeader'] != true) {
      final accessToken = await _ref
          .read(authLocalDataSourceProvider)
          .getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final options = err.requestOptions;

    if (statusCode != 401) {
      return handler.next(err);
    }
    if (options.path.contains('/v1/users/refresh') ||
        options.path.contains('/users/refresh')) {
      logger.w('[AuthInterceptor] 401 on refresh request');
      await _forceLogout();
      return handler.next(err);
    }
    if (options.extra['skipAuthRefresh'] == true ||
        options.extra['authRefreshed'] == true) {
      logger.w(
        '[AuthInterceptor] 401 after refresh for ${options.method} ${options.path}',
      );
      await _forceLogout();
      return handler.next(err);
    }

    logger.w(
      '[AuthInterceptor] 401 detected for ${options.method} ${options.path}',
    );

    final loadingController = _ref.read(
      globalLoadingControllerProvider.notifier,
    );
    loadingController.show(message: 'Hang on!');

    try {
      for (var attempt = 1; attempt <= 3; attempt++) {
        logger.i('[AuthInterceptor] refresh attempt $attempt/3');
        final newToken = await _coordinator.refreshAccessToken();
        if (newToken == null) {
          logger.w('[AuthInterceptor] refresh failed; backoff 5s');
          if (attempt < 3) {
            await Future.delayed(const Duration(seconds: 5));
          }
          continue;
        }

        logger.i('[AuthInterceptor] refresh success');
        try {
          final response = await _retryRequest(options, newToken);
          return handler.resolve(response);
        } on DioException catch (retryError, stackTrace) {
          logger.e(
            '[AuthInterceptor] retry failed',
            error: retryError,
            stackTrace: stackTrace,
          );
          return handler.next(retryError);
        }
      }

      logger.w('[AuthInterceptor] refresh exhausted; forcing logout');
      await _forceLogout();
      return handler.next(err);
    } finally {
      loadingController.hide();
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $accessToken';
    final extra = Map<String, dynamic>.from(requestOptions.extra);
    extra['skipAuthRefresh'] = true;
    extra['authRefreshed'] = true;

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        followRedirects: requestOptions.followRedirects,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: extra,
      ),
    );
  }

  Future<void> _forceLogout() async {
    await _ref.read(authControllerProvider.notifier).logoutLocalOnly();
    _ref.read(goRouterProvider).go('/login');
  }
}
