import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_response.dart';
import 'user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<UserDTO> login(String email, String password);
  Future<UserDTO> signUp(String firstName, String lastName, String email, String password);
  Future<String> requestPasswordReset(String email);
  Future<String> confirmPasswordReset(String resetToken, String password);
  Future<UserDTO> signInWithGoogle(); // Returns UserDTO if successful
  Future<UserDTO> getCurrentUser();
  Future<UserDTO> refresh(String accessToken, String refreshToken);
  Future<void> logout();
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<UserDTO> login(String email, String password) async {
    try {
      final response = await _dio.post('/v1/users/login', data: {
        'email': email,
        'password': password,
      });
      final api = APIResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserDTO.fromJson(_asMap(json)),
      );
      if (api.data == null) {
        throw StateError('Missing user data');
      }
      return api.data!;
    } catch (e) {
      logger.e('Login failed', error: e);
      rethrow;
    }
  }

  @override
  Future<UserDTO> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post('/v1/users/signup', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      });
      final api = APIResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserDTO.fromJson(_asMap(json)),
      );
      if (api.data == null) {
        throw StateError('Missing user data');
      }
      return api.data!;
    } catch (e) {
      logger.e('Sign up failed', error: e);
      rethrow;
    }
  }

  @override
  Future<String> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post('/v1/users/password-reset/request', data: {
        'email': email,
      });
      final api = APIResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
      return api.detail ?? 'Password reset link sent.';
    } catch (e) {
      logger.e('Password reset request failed', error: e);
      rethrow;
    }
  }

  @override
  Future<String> confirmPasswordReset(String resetToken, String password) async {
    try {
      final response = await _dio.patch('/v1/users/password-reset/confirm', data: {
        'resetToken': resetToken,
        'password': password,
      });
      final api = APIResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );
      return api.detail ?? 'Password updated successfully.';
    } catch (e) {
      logger.e('Confirm password reset failed', error: e);
      rethrow;
    }
  }

  @override
  Future<UserDTO> signInWithGoogle() async {
    // TODO: Implement Google Sign In
    // 1. Trigger Google Sign In Flow
    // 2. Get Token
    // 3. Send Token to Backend -> get UserDTO
    throw UnimplementedError('Google Sign In not implemented yet');
  }

  @override
  Future<UserDTO> getCurrentUser() async {
    try {
      final response = await _dio.get('/v1/users/me');
      final api = APIResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserDTO.fromJson(_asMap(json)),
      );
      if (api.statusCode != 200 || api.data == null) {
        throw ApiResponseException(
          api.detail ?? 'Failed to fetch user profile',
          statusCode: api.statusCode,
        );
      }
      return api.data!;
    } catch (e) {
       logger.e('Get current user failed', error: e);
      rethrow;
    }
  }

  @override
  Future<UserDTO> refresh(String accessToken, String refreshToken) async {
    try {
      final response = await _dio.post(
        '/v1/users/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      final api = APIResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserDTO.fromJson(_asMap(json)),
      );
      if (api.data == null) {
        throw StateError('Missing user data');
      }
      return api.data!;
    } catch (e) {
      logger.e('Token refresh failed', error: e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/v1/users/logout');
    } catch (e) {
      logger.e('Logout failed', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/v1/users/account');
    } catch (e) {
      logger.e('Delete account failed', error: e);
      rethrow;
    }
  }

  Map<String, dynamic> _asMap(Object? json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    return <String, dynamic>{};
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});
