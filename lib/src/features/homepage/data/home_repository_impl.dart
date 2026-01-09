import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/network/api_error_classifier.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/failure.dart';
import '../domain/home_repository.dart';
import '../domain/scenario_option.dart';
import 'home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ScenarioOption>>> getScenarioOptions() async {
    try {
      final dtos = await _remoteDataSource.getScenarioOptions();
      final entities = dtos.map((dto) => dto.toDomain()).toList();
      return Right(entities);
    } on ApiResponseException catch (e, stackTrace) {
      return Left(ServerFailure(
        e.message,
        statusCode: e.statusCode,
        stackTrace: stackTrace,
      ));
    } on DioException catch (e, stackTrace) {
      final errorType = ApiErrorClassifier.classify(e);
      if (errorType == ApiErrorType.network) {
        return Left(ConnectionFailure(
          'Unable to connect. Please check your connection.',
          stackTrace,
        ));
      }
      return Left(ServerFailure(
        e.message ?? 'Failed to load scenarios',
        statusCode: e.response?.statusCode,
        stackTrace: stackTrace,
      ));
    } catch (e, stackTrace) {
      return Left(ServerFailure(e.toString(), stackTrace: stackTrace));
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(homeRemoteDataSourceProvider));
});
