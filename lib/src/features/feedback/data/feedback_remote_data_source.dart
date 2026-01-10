import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import 'feedback_dto.dart';

abstract class FeedbackRemoteDataSource {
  Future<FeedbackDTO> getSessionFeedback(String sessionId);
  
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final Dio _dio;

  FeedbackRemoteDataSourceImpl(this._dio);

  @override
  Future<FeedbackDTO> getSessionFeedback(String sessionId) async {
    final response = await _dio.get('/v1/sessions/$sessionId/feedback');
    return FeedbackDTO.fromJson(response.data);
  }
}

final feedbackRemoteDataSourceProvider = Provider<FeedbackRemoteDataSource>((ref) {
  return FeedbackRemoteDataSourceImpl(ref.watch(dioProvider));
});
