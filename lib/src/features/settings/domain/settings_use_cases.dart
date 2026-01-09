import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'settings_models.dart';
import 'settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<Either<Failure, SettingsView>> call({String? deviceId}) {
    return _repository.getSettings(deviceId: deviceId);
  }
}

class UpdateSettingsUseCase {
  final SettingsRepository _repository;

  UpdateSettingsUseCase(this._repository);

  Future<Either<Failure, SettingsView>> call(SettingsRequest request) {
    return _repository.updateSettings(request);
  }
}

class UpdateDeviceStateUseCase {
  final SettingsRepository _repository;

  UpdateDeviceStateUseCase(this._repository);

  Future<Either<Failure, NotificationView>> call(
    DevicePushState devicePushState,
  ) {
    return _repository.updateDeviceState(devicePushState);
  }
}
