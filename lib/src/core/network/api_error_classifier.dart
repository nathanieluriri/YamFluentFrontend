import 'package:dio/dio.dart';

enum ApiErrorType {
  auth,
  network,
  server,
  rateLimit,
  other,
}

class ApiErrorClassifier {
  static ApiErrorType classify(DioException exception) {
    final statusCode = exception.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return ApiErrorType.auth;
    }
    if (statusCode == 429) {
      return ApiErrorType.rateLimit;
    }
    if (statusCode != null && statusCode >= 500) {
      return ApiErrorType.server;
    }
    if (_isNetworkError(exception)) {
      return ApiErrorType.network;
    }
    return ApiErrorType.other;
  }

  static bool isAuthStatus(int? statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  static bool _isNetworkError(DioException exception) {
    return exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.connectionError ||
        exception.response == null;
  }
}
