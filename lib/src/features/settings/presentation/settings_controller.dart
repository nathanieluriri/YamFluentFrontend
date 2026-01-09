import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/failure.dart';
import '../data/settings_local_data_source.dart';
import '../data/settings_repository_impl.dart';
import '../domain/settings_enums.dart';
import '../domain/settings_models.dart';
import '../domain/settings_use_cases.dart';

final getSettingsUseCaseProvider = Provider<GetSettingsUseCase>((ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final updateSettingsUseCaseProvider = Provider<UpdateSettingsUseCase>((ref) {
  return UpdateSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final updateDeviceStateUseCaseProvider = Provider<UpdateDeviceStateUseCase>((ref) {
  return UpdateDeviceStateUseCase(ref.watch(settingsRepositoryProvider));
});

class SettingsController extends AsyncNotifier<SettingsView> {
  @override
  Future<SettingsView> build() async {
    final deviceId = await ref.read(settingsLocalDataSourceProvider).getOrCreateDeviceId();
    final result = await ref.read(getSettingsUseCaseProvider)(deviceId: deviceId);
    return result.fold(
      (failure) => throw failure as Object,
      (settings) => settings,
    );
  }

  Future<Failure?> updatePrimaryGoals(List<MainGoals> goals) {
    return _updateSettings(
      SettingsRequest(
        profileUpdates: ProfileUpdates(mainGoals: goals),
      ),
    );
  }

  Future<Failure?> updateDailyPracticeTime(DailyPracticeTime time) {
    return _updateSettings(
      SettingsRequest(
        profileUpdates: ProfileUpdates(dailyPracticeTime: time),
      ),
    );
  }

  Future<Failure?> resetAccount() {
    return _updateSettings(
      const SettingsRequest(
        account: AccountAction(resetAccount: true),
      ),
    );
  }

  Future<Failure?> deleteAccount() {
    return _updateSettings(
      const SettingsRequest(
        account: AccountAction(deleteAccount: true),
      ),
    );
  }

  Future<Failure?> updateNotifications(bool enabled) async {
    final current = state.value;
    if (current == null) {
      return const ServerFailure('Settings not loaded.');
    }

    state = const AsyncValue.loading();

    final settingsResult = await ref.read(updateSettingsUseCaseProvider)(
      SettingsRequest(
        notifications: NotificationBlock(
          preference: PushPreference(enabled: enabled),
        ),
      ),
    );

    return settingsResult.fold((failure) {
      state = AsyncValue.data(current);
      return failure;
    }, (settings) async {
      Failure? deviceFailure;
      var updatedSettings = settings;

      final deviceId =
          await ref.read(settingsLocalDataSourceProvider).getOrCreateDeviceId();
      final deviceState = DevicePushState(
        deviceId: deviceId,
        platform: _resolveDevicePlatform(),
        permissionGranted: enabled,
        lastSyncedAt: DateTime.now(),
      );
      final deviceResult =
          await ref.read(updateDeviceStateUseCaseProvider)(deviceState);
      deviceResult.fold(
        (failure) => deviceFailure = failure,
        (notification) {
          updatedSettings = updatedSettings.copyWith(
            notifications: notification,
          );
        },
      );

      state = AsyncValue.data(updatedSettings);
      return deviceFailure;
    });
  }

  Future<Failure?> _updateSettings(SettingsRequest request) async {
    final current = state.value;
    if (current == null) {
      return const ServerFailure('Settings not loaded.');
    }

    state = const AsyncValue.loading();
    final result = await ref.read(updateSettingsUseCaseProvider)(request);

    return result.fold((failure) {
      state = AsyncValue.data(current);
      return failure;
    }, (settings) {
      state = AsyncValue.data(settings);
      return null;
    });
  }

  DevicePlatform _resolveDevicePlatform() {
    if (kIsWeb) {
      return DevicePlatform.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return DevicePlatform.ios;
      case TargetPlatform.android:
        return DevicePlatform.android;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return DevicePlatform.android;
    }
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsView>(() {
  return SettingsController();
});
