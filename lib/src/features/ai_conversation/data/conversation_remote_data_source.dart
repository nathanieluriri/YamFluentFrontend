import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import 'message_dto.dart';
import 'session_dto.dart';

abstract class ConversationRemoteDataSource {
  Future<SessionDTO> startSession(String scenarioId);
  Future<MessageDTO> sendMessage(String sessionId, String content);
  Future<SessionDTO> uploadTurnAudio(
    String sessionId,
    int turnIndex,
    String filePath,
  );
  Future<SessionDTO> endSession(String sessionId);
}

class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  final Dio _dio;

  ConversationRemoteDataSourceImpl(this._dio);

  @override
  Future<SessionDTO> startSession(String scenarioId) async {
    final response = await _dio.post(
      '/v1/users/sessions/',
      data: {'scenario': scenarioId},
    );
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => SessionDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to start session',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  @override
  Future<MessageDTO> sendMessage(String sessionId, String content) async {
    throw UnsupportedError(
      'Text messages are no longer supported. Use audio upload for session turns.',
    );
  }

  @override
  Future<SessionDTO> uploadTurnAudio(
    String sessionId,
    int turnIndex,
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.patch(
      '/v1/users/sessions/$sessionId/$turnIndex',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => SessionDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to upload turn audio',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  @override
  Future<SessionDTO> endSession(String sessionId) async {
    final response = await _dio.get('/v1/users/sessions/$sessionId');
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => SessionDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to fetch session',
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

final conversationRemoteDataSourceProvider =
    Provider<ConversationRemoteDataSource>((ref) {
      return ConversationRemoteDataSourceImpl(ref.watch(dioProvider));
    });
