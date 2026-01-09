class OnboardingDraft {
  final String? nativeLanguage;
  final String? currentProficiency;
  final List<String> mainGoals;
  final String? learnerType;
  final String? dailyPracticeTime;

  const OnboardingDraft({
    this.nativeLanguage,
    this.currentProficiency,
    this.mainGoals = const [],
    this.learnerType,
    this.dailyPracticeTime,
  });

  OnboardingDraft copyWith({
    String? nativeLanguage,
    String? currentProficiency,
    List<String>? mainGoals,
    String? learnerType,
    String? dailyPracticeTime,
  }) {
    return OnboardingDraft(
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      currentProficiency: currentProficiency ?? this.currentProficiency,
      mainGoals: mainGoals ?? this.mainGoals,
      learnerType: learnerType ?? this.learnerType,
      dailyPracticeTime: dailyPracticeTime ?? this.dailyPracticeTime,
    );
  }

  bool get isComplete =>
      nativeLanguage != null &&
      currentProficiency != null &&
      mainGoals.isNotEmpty &&
      learnerType != null &&
      dailyPracticeTime != null;
}
