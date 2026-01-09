import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'onboarding_draft.dart';
import 'onboarding_repository.dart';

class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  Future<Either<Failure, void>> call(OnboardingDraft draft) {
    return _repository.completeOnboarding(draft);
  }
}
