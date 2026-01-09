import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'onboarding_options.dart';
import 'onboarding_repository.dart';

class GetOnboardingOptionsUseCase {
  final OnboardingRepository _repository;

  GetOnboardingOptionsUseCase(this._repository);

  Future<Either<Failure, OnboardingOptions>> call() {
    return _repository.getOptions();
  }
}
