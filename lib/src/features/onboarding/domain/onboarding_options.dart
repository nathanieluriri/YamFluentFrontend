import 'onboarding_option_item.dart';

class OnboardingOptions {
  final List<String> nativeLanguages;
  final List<OnboardingOptionItem> currentProficiencies;
  final List<String> mainGoals;
  final List<OnboardingOptionItem> learnerTypes;
  final List<String> dailyPracticeTimes;

  const OnboardingOptions({
    required this.nativeLanguages,
    required this.currentProficiencies,
    required this.mainGoals,
    required this.learnerTypes,
    required this.dailyPracticeTimes,
  });
}
