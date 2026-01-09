import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'feedback_entity.dart';
import 'feedback_repository.dart';

class AnalyzeSessionUseCase {
  final FeedbackRepository _repository;

  AnalyzeSessionUseCase(this._repository);

  Future<Either<Failure, FeedbackEntity>> call(String sessionId) {
    return _repository.getSessionFeedback(sessionId);
  }
}
