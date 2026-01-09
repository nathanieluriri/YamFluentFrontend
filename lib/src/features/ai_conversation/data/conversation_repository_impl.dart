import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import '../domain/conversation_repository.dart';
import 'sessions_api_client.dart';
import 'session_dto.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final SessionsApiClient _apiClient;

  ConversationRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, SessionDTO>> createSession(String scenario) async {
    try {
      final dto = await _apiClient.createSession(scenario);
      return Right(dto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionDTO>> getSessionById(String sessionId) async {
    try {
      final dto = await _apiClient.getSessionById(sessionId);
      return Right(dto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SessionDTO>>> listSessions({
    String? start,
    String? stop,
    int? pageNumber,
    String? filters,
  }) async {
    try {
      final sessions = await _apiClient.listSessions(
        start: start,
        stop: stop,
        pageNumber: pageNumber,
        filters: filters,
      );
      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionDTO>> uploadTurnAudio(
    String sessionId,
    int turnIndex,
    String filePath,
  ) async {
    try {
      final dto = await _apiClient.uploadUserTurnAudio(sessionId, turnIndex, filePath);
      return Right(dto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<void> get messageStream => const Stream.empty();
}

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl(ref.watch(sessionsApiClientProvider));
});
