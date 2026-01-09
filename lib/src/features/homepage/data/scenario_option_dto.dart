import '../domain/scenario_option.dart';

class ScenarioOptionDTO {
  final String scenarioName;
  final int difficultyRating;
  final String? imageUrl;
  final String? benefits;

  const ScenarioOptionDTO({
    required this.scenarioName,
    required this.difficultyRating,
    this.imageUrl,
    this.benefits,
  });

  factory ScenarioOptionDTO.fromJson(Map<String, dynamic> json) {
    final rawName = json['scenarioName']?.toString().trim() ?? '';
    final difficultyRaw = json['scenarioDifficultyRating'];
    final difficulty = difficultyRaw is int
        ? difficultyRaw
        : difficultyRaw is String
            ? int.tryParse(difficultyRaw) ?? 1
            : 1;

    return ScenarioOptionDTO(
      scenarioName: rawName.isEmpty ? 'practice' : rawName,
      difficultyRating: difficulty.clamp(1, 5),
      imageUrl: json['scenerioImageUrl']?.toString(),
      benefits: json['benefitsOfScenerio']?.toString(),
    );
  }

  ScenarioOption toDomain() {
    return ScenarioOption(
      scenarioName: scenarioName,
      difficultyRating: difficultyRating,
      imageUrl: imageUrl,
      benefits: benefits,
    );
  }
}
