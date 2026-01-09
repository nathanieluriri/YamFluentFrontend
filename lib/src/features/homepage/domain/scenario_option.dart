class ScenarioOption {
  final String scenarioName;
  final int difficultyRating;
  final String? imageUrl;
  final String? benefits;

  const ScenarioOption({
    required this.scenarioName,
    required this.difficultyRating,
    this.imageUrl,
    this.benefits,
  });

  String get displayName {
    final normalized = scenarioName.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) {
      return 'Practice';
    }
    final words = normalized.split(RegExp(r'\\s+'));
    return words
        .map((word) {
          if (word.isEmpty) return '';
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .where((word) => word.isNotEmpty)
        .join(' ');
  }

  String get difficultyLabel {
    switch (difficultyRating) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }
}
