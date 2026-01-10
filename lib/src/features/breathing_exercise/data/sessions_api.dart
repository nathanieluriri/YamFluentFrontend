import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import '../../ai_conversation/data/session_dto.dart';

final sessionsApiProvider = Provider<SessionsApi>((ref) {
  return SessionsApi(ref.watch(dioProvider));
});

class SessionsApi {
  final Dio _dio;

  SessionsApi(this._dio);

  Future<String> createSession(String scenario) async {
    const int maxRetries = 2;
    int attempt = 0;

    
    

    while (true) {
      try {
        final response = await _dio.post(
          '/v1/users/sessions/',
          data: {'scenario': scenario},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return _parseSessionId(response);
        } else {
          
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: 'Failed to create session: ${response.statusCode}',
          );
        }
      } on DioException catch (e) {
        attempt++;
        if (attempt > maxRetries) {
          rethrow;
        }

        await Future.delayed(
          Duration(milliseconds: 500 * (1 << attempt)),
        ); 
      } catch (e) {
        rethrow;
      }
    }
  }

  String _parseSessionId(Response response) {
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => SessionDTO.fromJson(_asMap(json)),
    );
    final session = api.data;
    if (session == null || session.id.isEmpty) {
      throw ApiResponseException(
        api.detail ?? 'Failed to create session',
        statusCode: api.statusCode,
      );
    }
    return session.id;
  }

  Map<String, dynamic> _asMap(Object? json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    return <String, dynamic>{};
  }
}
