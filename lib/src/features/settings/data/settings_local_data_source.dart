import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class SettingsLocalDataSource {
  Future<void> saveThemeMode(bool isDarkMode);
  Future<bool> getThemeMode();
  Future<String> getOrCreateDeviceId();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const boxName = 'settingsBase';
  static const keyTheme = 'isDarkMode';
  static const keyDeviceId = 'device_id';

  @override
  Future<void> saveThemeMode(bool isDarkMode) async {
    final box = await Hive.openBox<dynamic>(boxName);
    await box.put(keyTheme, isDarkMode);
  }

  @override
  Future<bool> getThemeMode() async {
    final box = await Hive.openBox<dynamic>(boxName);
    return box.get(keyTheme, defaultValue: false) as bool;
  }

  @override
  Future<String> getOrCreateDeviceId() async {
    final box = await Hive.openBox<dynamic>(boxName);
    final existing = box.get(keyDeviceId);
    if (existing is String && existing.trim().isNotEmpty) {
      return existing;
    }
    final newId = _generateDeviceId();
    await box.put(keyDeviceId, newId);
    return newId;
  }

  String _generateDeviceId() {
    final rand = Random();
    final buffer = StringBuffer('device_');
    buffer.write(DateTime.now().millisecondsSinceEpoch);
    for (var i = 0; i < 6; i++) {
      buffer.write(rand.nextInt(16).toRadixString(16));
    }
    return buffer.toString();
  }
}

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSourceImpl();
});
