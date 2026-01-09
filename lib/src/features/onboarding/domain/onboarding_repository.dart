import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'onboarding_draft.dart';
import 'onboarding_options.dart';

abstract interface class OnboardingRepository {
  Future<Either<Failure, OnboardingOptions>> getOptions();
  Future<Either<Failure, void>> completeOnboarding(OnboardingDraft draft);
}
