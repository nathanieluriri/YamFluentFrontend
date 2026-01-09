import '../domain/onboarding_options.dart';
import '../domain/onboarding_option_item.dart';

class OnboardingOptionsDTO {
  final List<String> nativeLanguages;
  final List<OnboardingOptionItem> currentProficiencies;
  final List<String> mainGoals;
  final List<OnboardingOptionItem> learnerTypes;
  final List<String> dailyPracticeTimes;

  const OnboardingOptionsDTO({
    required this.nativeLanguages,
    required this.currentProficiencies,
    required this.mainGoals,
    required this.learnerTypes,
    required this.dailyPracticeTimes,
  });

  factory OnboardingOptionsDTO.fromJson(Map<String, dynamic> json) {
    final proficiencyRaw = _asStringList(json['currentProficiencies']);
    final learnerRaw = _asStringList(json['learnerTypes']);
    return OnboardingOptionsDTO(
      nativeLanguages: _asStringList(json['nativeLanguages']),
      currentProficiencies: _parseOptionItems(proficiencyRaw),
      mainGoals: _asStringList(json['mainGoals']),
      learnerTypes: _parseOptionItems(learnerRaw),
      dailyPracticeTimes: _asStringList(json['dailyPracticeTimes']),
    );
  }

  OnboardingOptions toDomain() {
    return OnboardingOptions(
      nativeLanguages: nativeLanguages,
      currentProficiencies: currentProficiencies,
      mainGoals: mainGoals,
      learnerTypes: learnerTypes,
      dailyPracticeTimes: dailyPracticeTimes,
    );
  }

  static List<String> _asStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  static List<OnboardingOptionItem> _parseOptionItems(List<String> rawItems) {
    final pattern = RegExp(r'\[(.+?)\]\s*\((.+?)\)\s*(.*)');
    return rawItems.map((raw) {
      final trimmed = raw.trim();
      final match = pattern.firstMatch(trimmed);
      if (match == null) {
        return OnboardingOptionItem(
          value: raw,
          title: trimmed,
          description: '',
          imageUrl: '',
        );
      }
      final imageUrl = match.group(1)?.trim() ?? '';
      final title = match.group(2)?.trim() ?? trimmed;
      final description = match.group(3)?.trim() ?? '';
      return OnboardingOptionItem(
        value: raw,
        title: title,
        description: description,
        imageUrl: imageUrl,
      );
    }).toList();
  }
}
