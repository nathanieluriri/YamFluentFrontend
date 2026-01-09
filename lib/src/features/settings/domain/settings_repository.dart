import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'settings_models.dart';

abstract interface class SettingsRepository {
  Future<Either<Failure, SettingsView>> getSettings({String? deviceId});
  Future<Either<Failure, SettingsView>> updateSettings(SettingsRequest request);
  Future<Either<Failure, NotificationView>> updateDeviceState(
    DevicePushState devicePushState,
  );
}
