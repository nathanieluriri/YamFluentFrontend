import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import '../domain/onboarding_draft.dart';
import '../domain/onboarding_options.dart';
import '../domain/onboarding_repository.dart';
import 'onboarding_remote_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource _remoteDataSource;

  OnboardingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, OnboardingOptions>> getOptions() async {
    try {
      final dto = await _remoteDataSource.getOptions();
      return Right(dto.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding(OnboardingDraft draft) async {
    try {
      await _remoteDataSource.completeOnboarding(draft);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingRemoteDataSourceProvider));
});
