import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/network/api_error_classifier.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/failure.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userDto = await _remoteDataSource.login(email, password);
      return Right(userDto.toDomain());
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e), statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUp(String name, String email, String password) async {
    try {
      final parts = name.trim().split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final userDto = await _remoteDataSource.signUp(firstName, lastName, email, password);
      return Right(userDto.toDomain());
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e), statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestPasswordReset(String email) async {
    try {
      final detail = await _remoteDataSource.requestPasswordReset(email);
      return Right(detail);
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e), statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> confirmPasswordReset(String resetToken, String password) async {
    try {
      final detail = await _remoteDataSource.confirmPasswordReset(resetToken, password);
      return Right(detail);
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e), statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final userDto = await _remoteDataSource.signInWithGoogle();
      return Right(userDto.toDomain());
    } catch (e) {
       return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userDto = await _remoteDataSource.getCurrentUser();
      return Right(userDto.toDomain());
    } on ApiResponseException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> refresh(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      final userDto = await _remoteDataSource.refresh(accessToken, refreshToken);
      return Right(userDto.toDomain());
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e), statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e), statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_messageFromDio(e), statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _mapDioFailure(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final type = ApiErrorClassifier.classify(exception);
    if (type == ApiErrorType.network) {
      return const ConnectionFailure('Network error. Please check your connection.');
    }
    if (type == ApiErrorType.server) {
      return ServerFailure('Server error. Please try again.', statusCode: statusCode);
    }
    if (type == ApiErrorType.rateLimit) {
      return ServerFailure('Too many requests. Please try again shortly.',
          statusCode: statusCode);
    }
    if (type == ApiErrorType.auth) {
      return ServerFailure(_messageFromDio(exception), statusCode: statusCode);
    }
    return ServerFailure(exception.message ?? 'Server error', statusCode: statusCode);
  }

  String _messageFromDio(DioException exception) {
    final statusCode = exception.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      final detail = _extractDetail(exception.response?.data);
      if (detail.isNotEmpty) {
        return detail;
      }
      return exception.message ?? 'Unauthorized.';
    }
    return exception.message ?? 'Server error';
  }

  String _extractDetail(Object? data) {
    if (data is Map) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail != null) {
        return detail.toString();
      }
    }
    return '';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});
