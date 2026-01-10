import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/utils/failure.dart';
import '../domain/coaching_tip.dart';
import '../domain/tip.dart';
import 'coaching_tip_dto.dart';


abstract interface class TipsRepository {
  Future<Either<Failure, List<Tip>>> getTips();
  Future<Either<Failure, CoachingTip>> createTip(String sessionId);
  Future<Either<Failure, CoachingTip>> getTipDetail(String tipId);
}


class TipsRemoteDataSource {
  final Dio _dio;

  TipsRemoteDataSource(this._dio);

  Future<List<CoachingTipListItemDTO>> getTips() async {
    final response = await _dio.get('/v1/users/coaching-tips/');
    final api = APIResponse.fromJson(response.data as Map<String, dynamic>, (
      json,
    ) {
      final list = json is List ? json : <Object?>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(CoachingTipListItemDTO.fromJson)
          .toList();
    });
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to load coaching tips',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  Future<CoachingTipDTO> createTip(String sessionId) async {
    final response = await _dio.post(
      '/v1/users/coaching-tips/',
      data: {'session_id': sessionId, 'sessionId': sessionId},
    );
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => CoachingTipDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to create coaching tip',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }

  Future<CoachingTipDTO> getTipDetail(String tipId) async {
    final response = await _dio.get('/v1/users/coaching-tips/$tipId');
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => CoachingTipDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to load coaching tip',
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


class TipsRepositoryImpl implements TipsRepository {
  final TipsRemoteDataSource _dataSource;
  TipsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Tip>>> getTips() async {
    try {
      final tips = await _dataSource.getTips();
      final mapped = tips.map(_mapTip).toList();
      return Right(mapped);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoachingTip>> createTip(String sessionId) async {
    try {
      final tip = await _dataSource.createTip(sessionId);
      return Right(_mapDetail(tip));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoachingTip>> getTipDetail(String tipId) async {
    try {
      final tip = await _dataSource.getTipDetail(tipId);
      return Right(_mapDetail(tip));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Tip _mapTip(CoachingTipListItemDTO dto) {
    final preview = dto.preview?.trim();
    return Tip(
      id: dto.id,
      title: 'Coaching Tip',
      content: preview?.isNotEmpty == true
          ? preview!
          : 'Open to view tip details.',
      category: 'Coaching',
    );
  }

  CoachingTip _mapDetail(CoachingTipDTO dto) {
    return CoachingTip(
      id: dto.id,
      sessionId: dto.sessionId,
      userId: dto.userId,
      createdAt: dto.createdAt,
      tipText: dto.tipText,
      practiceWords: dto.practiceWords ?? const [],
      providerMeta: dto.providerMeta,
      feedback: dto.feedback,
      promptVersion: dto.promptVersion,
    );
  }
}


final tipsRemoteDataSourceProvider = Provider(
  (ref) => TipsRemoteDataSource(ref.watch(dioProvider)),
);

final tipsRepositoryProvider = Provider<TipsRepository>((ref) {
  return TipsRepositoryImpl(ref.watch(tipsRemoteDataSourceProvider));
});
