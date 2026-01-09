import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/onboarding_repository_impl.dart';
import '../domain/complete_onboarding_use_case.dart';
import '../domain/get_onboarding_options_use_case.dart';
import '../domain/onboarding_draft.dart';
import '../domain/onboarding_options.dart';

final getOnboardingOptionsUseCaseProvider = Provider<GetOnboardingOptionsUseCase>((ref) {
  return GetOnboardingOptionsUseCase(ref.watch(onboardingRepositoryProvider));
});

final completeOnboardingUseCaseProvider = Provider<CompleteOnboardingUseCase>((ref) {
  return CompleteOnboardingUseCase(ref.watch(onboardingRepositoryProvider));
});

class OnboardingOptionsController extends AsyncNotifier<OnboardingOptions> {
  @override
  Future<OnboardingOptions> build() async {
    final useCase = ref.read(getOnboardingOptionsUseCaseProvider);
    final result = await useCase();
    return result.fold(
      (failure) => throw failure as Object,
      (options) => options,
    );
  }
}

final onboardingOptionsProvider =
    AsyncNotifierProvider<OnboardingOptionsController, OnboardingOptions>(() {
  return OnboardingOptionsController();
});

class OnboardingDraftController extends StateNotifier<OnboardingDraft> {
  OnboardingDraftController() : super(const OnboardingDraft());

  void setNativeLanguage(String value) {
    state = state.copyWith(nativeLanguage: value);
  }

  void setCurrentProficiency(String value) {
    state = state.copyWith(currentProficiency: value);
  }

  void toggleGoal(String value) {
    final goals = List<String>.from(state.mainGoals);
    if (goals.contains(value)) {
      goals.remove(value);
    } else {
      goals.add(value);
    }
    state = state.copyWith(mainGoals: goals);
  }

  void setLearnerType(String value) {
    state = state.copyWith(learnerType: value);
  }

  void setDailyPracticeTime(String value) {
    state = state.copyWith(dailyPracticeTime: value);
  }
}

final onboardingDraftProvider =
    StateNotifierProvider<OnboardingDraftController, OnboardingDraft>((ref) {
  return OnboardingDraftController();
});

class OnboardingSubmitController extends AsyncNotifier<void> {
  bool _hasSubmitted = false;

  bool get hasSubmitted => _hasSubmitted;

  @override
  Future<void> build() async {}

  Future<void> submit(OnboardingDraft draft) async {
    _hasSubmitted = true;
    state = const AsyncValue.loading();
    final useCase = ref.read(completeOnboardingUseCaseProvider);
    final result = await useCase(draft);
    state = result.fold(
      (failure) => AsyncValue.error(failure as Object, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  void resetSubmissionFlag() {
    _hasSubmitted = false;
  }
}

final onboardingSubmitProvider =
    AsyncNotifierProvider<OnboardingSubmitController, void>(() {
  return OnboardingSubmitController();
});
