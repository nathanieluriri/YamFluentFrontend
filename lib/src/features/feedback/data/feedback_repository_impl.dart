import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import '../domain/feedback_entity.dart';
import '../domain/feedback_repository.dart';
import '../domain/progress.dart';
import 'feedback_remote_data_source.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource _remoteDataSource;

  FeedbackRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, FeedbackEntity>> getSessionFeedback(String sessionId) async {
    try {
      final dto = await _remoteDataSource.getSessionFeedback(sessionId);
      return Right(dto.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Progress>> getUserProgress(String userId) async {
    // TODO: Implement progress fetching
    // Returning dummy progress for now
    return Right(Progress(
      userId: userId,
      currentStreak: 5,
      totalSessions: 12,
      averageFluencyScore: 8.5,
      activeDays: [],
    ));
  }
}

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepositoryImpl(ref.watch(feedbackRemoteDataSourceProvider));
});
