import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/utils/logger.dart';
import '../../authentication/data/auth_local_data_source.dart';
import 'scenario_option_dto.dart';

abstract class HomeRemoteDataSource {
  Future<List<ScenarioOptionDTO>> getScenarioOptions();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;
  final AuthLocalDataSource _authLocalDataSource;

  HomeRemoteDataSourceImpl(this._dio, this._authLocalDataSource);

  @override
  Future<List<ScenarioOptionDTO>> getScenarioOptions() async {
    final accessToken = await _authLocalDataSource.getAccessToken();
    logger.i('GET /v1/users/scenerio/options start');
    final response = await _dio.get(
      '/v1/users/scenerio/options',
      options: Options(
        headers: accessToken == null
            ? null
            : <String, String>{'Authorization': 'Bearer $accessToken'},
      ),
    );
    logger.i('GET /v1/users/scenerio/options status=${response.statusCode}');

    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final list = json is List ? json : <Object?>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(ScenarioOptionDTO.fromJson)
            .toList();
      },
    );

    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to fetch scenarios',
        statusCode: api.statusCode,
      );
    }

    final results = api.data!;
    logger.i('GET /v1/users/scenerio/options parsed count=${results.length}');
    return results;
  }
}

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSourceImpl(
    ref.watch(dioProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});
