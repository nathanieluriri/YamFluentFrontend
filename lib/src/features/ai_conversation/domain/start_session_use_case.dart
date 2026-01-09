import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'conversation_repository.dart';
import '../data/session_dto.dart';

class StartSessionUseCase {
  final ConversationRepository _repository;

  StartSessionUseCase(this._repository);

  Future<Either<Failure, SessionDTO>> call(String scenario) {
    return _repository.createSession(scenario);
  }
}
