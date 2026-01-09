class AppConfigs {
  final bool isDarkMode;
  final bool notificationsEnabled;

  const AppConfigs({
    required this.isDarkMode,
    required this.notificationsEnabled,
  });

  AppConfigs copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
  }) {
    return AppConfigs(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
