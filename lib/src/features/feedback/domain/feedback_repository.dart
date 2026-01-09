import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'feedback_entity.dart';
import 'progress.dart';

abstract interface class FeedbackRepository {
  Future<Either<Failure, FeedbackEntity>> getSessionFeedback(String sessionId);
  Future<Either<Failure, Progress>> getUserProgress(String userId);
}
