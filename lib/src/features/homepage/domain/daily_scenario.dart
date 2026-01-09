class DailyScenario {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String imageUrl;
  final bool isCompleted;

  const DailyScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.imageUrl,
    this.isCompleted = false,
  });
}
