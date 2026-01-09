import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import '../data/session_dto.dart';

abstract interface class ConversationRepository {
  Future<Either<Failure, SessionDTO>> createSession(String scenario);
  Future<Either<Failure, SessionDTO>> getSessionById(String sessionId);
  Future<Either<Failure, List<SessionDTO>>> listSessions({
    String? start,
    String? stop,
    int? pageNumber,
    String? filters,
  });
  Future<Either<Failure, SessionDTO>> uploadTurnAudio(
    String sessionId,
    int turnIndex,
    String filePath,
  );
  Stream<void> get messageStream;
}
