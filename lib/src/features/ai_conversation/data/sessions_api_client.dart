import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import 'session_dto.dart';

class SessionsApiClient {
  final Dio _dio;

  SessionsApiClient(this._dio);

  Future<SessionDTO> createSession(String scenario) async {
    final response = await _dio.post(
      '/v1/users/sessions/',
      data: {'scenario': scenario},
    );
    return _parseSessionResponse(response);
  }

  Future<SessionDTO> getSessionById(String id) async {
    final response = await _dio.get('/v1/users/sessions/$id');
    return _parseSessionResponse(response);
  }

  Future<List<SessionDTO>> listSessions({
    String? start,
    String? stop,
    int? pageNumber,
    String? filters,
  }) async {
    final response = await _dio.get(
      '/v1/users/sessions/',
      queryParameters: {
        if (start != null) 'start': start,
        if (stop != null) 'stop': stop,
        if (pageNumber != null) 'page_number': pageNumber,
        if (filters != null) 'filters': filters,
      },
    );
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map(SessionDTO.fromJson)
              .toList();
        }
        return <SessionDTO>[];
      },
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to list sessions',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  Future<SessionDTO> uploadUserTurnAudio(
    String sessionId,
    int turnIndex,
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });
    final response = await _dio.patch(
      '/v1/users/sessions/$sessionId/$turnIndex',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _parseSessionResponse(response);
  }

  SessionDTO _parseSessionResponse(Response response) {
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => SessionDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to load session',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  Map<String, dynamic> _asMap(Object? json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    return <String, dynamic>{};
  }
}

final sessionsApiClientProvider = Provider<SessionsApiClient>((ref) {
  return SessionsApiClient(ref.watch(dioProvider));
});
