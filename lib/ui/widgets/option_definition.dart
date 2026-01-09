import '../../src/features/onboarding/domain/onboarding_option_item.dart';

class OptionDefinition {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String value;

  const OptionDefinition({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.value,
  });
}

List<OptionDefinition> buildOptionDefinitions(List<OnboardingOptionItem> items) {
  return items.map((item) {
    return OptionDefinition(
      title: item.title,
      subtitle: item.description,
      imageUrl: item.imageUrl,
      value: item.value,
    );
  }).toList();
}
