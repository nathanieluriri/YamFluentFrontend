import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';
import 'settings_remote_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;

  SettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, SettingsView>> getSettings({String? deviceId}) async {
    try {
      final dto = await _remoteDataSource.getSettings(deviceId: deviceId);
      return Right(dto.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SettingsView>> updateSettings(
    SettingsRequest request,
  ) async {
    try {
      final dto = await _remoteDataSource.updateSettings(request);
      return Right(dto.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationView>> updateDeviceState(
    DevicePushState devicePushState,
  ) async {
    try {
      final dto = await _remoteDataSource.updateDeviceState(devicePushState);
      return Right(dto.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsRemoteDataSourceProvider));
});
