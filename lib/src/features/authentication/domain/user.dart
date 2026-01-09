class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? accessToken;
  final String? refreshToken;
  final bool onboardingCompleted;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.accessToken,
    this.refreshToken,
    required this.onboardingCompleted,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      other.id == id &&
      other.email == email &&
      other.onboardingCompleted == onboardingCompleted;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ onboardingCompleted.hashCode;
}
