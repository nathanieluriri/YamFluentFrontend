import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> clearTokens();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const boxName = 'auth_tokens';
  static const keyAccessToken = 'accessToken';
  static const keyRefreshToken = 'refreshToken';

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final box = await Hive.openBox<String>(boxName);
    await box.put(keyAccessToken, accessToken);
    await box.put(keyRefreshToken, refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    final box = await Hive.openBox<String>(boxName);
    await box.delete(keyAccessToken);
    await box.delete(keyRefreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    final box = await Hive.openBox<String>(boxName);
    return box.get(keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    final box = await Hive.openBox<String>(boxName);
    return box.get(keyRefreshToken);
  }
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});
