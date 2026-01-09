import '../domain/user.dart';

class UserDTO {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? accessToken;
  final String? refreshToken;
  final bool onboardingCompleted;

  const UserDTO({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.accessToken,
    this.refreshToken,
    required this.onboardingCompleted,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;
    final id =
        _stringOrEmpty(userJson['id']) ?? _stringOrEmpty(userJson['_id']) ?? '';
    final email = _stringOrEmpty(userJson['email']) ?? '';
    String? name = _stringOrEmpty(userJson['name']);
    if (name == null) {
      final first = _stringOrEmpty(userJson['firstName']);
      final last = _stringOrEmpty(userJson['lastName']);
      if (first != null || last != null) {
        name = [
          first,
          last,
        ].where((part) => part?.isNotEmpty ?? false).join(' ').trim();
        if (name.isEmpty) {
          name = null;
        }
      }
    }

    final photoUrl =
        _stringOrEmpty(userJson['photoUrl']) ??
        _stringOrEmpty(userJson['avatarUrl']);
    final tokensJson = json['tokens'] is Map<String, dynamic>
        ? json['tokens'] as Map<String, dynamic>
        : null;
    final accessToken =
        _stringOrEmpty(json['accessToken']) ??
        _stringOrEmpty(json['accessToken']) ??
        _stringOrEmpty(tokensJson?['accessToken']) ??
        _stringOrEmpty(tokensJson?['accessToken']) ??
        _stringOrEmpty(tokensJson?['token']);
    final refreshToken =
        _stringOrEmpty(json['refreshToken']) ??
        _stringOrEmpty(json['refreshToken']) ??
        _stringOrEmpty(tokensJson?['refreshToken']) ??
        _stringOrEmpty(tokensJson?['refreshToken']);
    final onboardingCompleted =
        _boolOrFalse(userJson['onboardingCompleted']) ??
        _boolOrFalse(json['onboardingCompleted']) ??
        false;

    return UserDTO(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      accessToken: accessToken,
      refreshToken: refreshToken,
      onboardingCompleted: onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      accessToken: accessToken,
      refreshToken: refreshToken,
      onboardingCompleted: onboardingCompleted,
    );
  }

  static String? _stringOrEmpty(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static bool? _boolOrFalse(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') {
        return true;
      }
      if (lower == 'false') {
        return false;
      }
    }
    if (value is num) {
      return value != 0;
    }
    return null;
  }
}
