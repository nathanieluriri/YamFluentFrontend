import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import 'settings_dto.dart';
import '../domain/settings_models.dart';

abstract class SettingsRemoteDataSource {
  Future<SettingsViewDTO> getSettings({String? deviceId});
  Future<SettingsViewDTO> updateSettings(SettingsRequest request);
  Future<NotificationViewDTO> updateDeviceState(DevicePushState deviceState);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio _dio;

  SettingsRemoteDataSourceImpl(this._dio);

  @override
  Future<SettingsViewDTO> getSettings({String? deviceId}) async {
    final response = await _dio.get(
      '/v1/users/settings/',
      queryParameters: deviceId == null ? null : {'device_id': deviceId},
    );
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => SettingsViewDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to load settings.',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  @override
  Future<SettingsViewDTO> updateSettings(SettingsRequest request) async {
    final payload = SettingsRequestDTO.fromDomain(request).toJson();
    final response = await _dio.patch(
      '/v1/users/settings/',
      data: payload,
    );
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => SettingsViewDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to update settings.',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  @override
  Future<NotificationViewDTO> updateDeviceState(
    DevicePushState deviceState,
  ) async {
    final payload = DevicePushStateDTO.fromDomain(deviceState).toJson();
    final response = await _dio.post(
      '/v1/users/settings/notifications/device-state',
      data: payload,
    );
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NotificationViewDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to update notifications.',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  Map<String, dynamic> _asMap(Object? json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    return <String, dynamic>{};
  }
}

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>(
  (ref) => SettingsRemoteDataSourceImpl(ref.watch(dioProvider)),
);
