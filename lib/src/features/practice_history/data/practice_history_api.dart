import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/practice_session_summary.dart';

class PracticeHistoryApi {
  final Dio _dio;

  PracticeHistoryApi(this._dio);

  Future<List<PracticeSessionSummary>> listSessions({
    int? start,
    int? stop,
    int? pageNumber,
    String? filters,
  }) async {
    final response = await _dio.get(
      '/v1/users/sessions/',
      queryParameters: {
        if (start != null) 'start': start,
        if (stop != null) 'stop': stop,
        if (pageNumber != null) 'page_number': pageNumber,
        if (filters != null) 'filters': filters,
      },
    );
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map(_SessionSummaryDTO.fromJson)
              .map((dto) => dto.toDomain())
              .toList();
        }
        return <PracticeSessionSummary>[];
      },
    );
    if (api.data == null) {
      throw ApiResponseException(
        api.detail ?? 'Failed to list sessions',
        statusCode: api.statusCode,
      );
    }
    return api.data!;
  }
}

final practiceHistoryApiProvider = Provider<PracticeHistoryApi>((ref) {
  return PracticeHistoryApi(ref.watch(dioProvider));
});

class _SessionSummaryDTO {
  final String id;
  final String scenario;
  final int? lastUpdated;
  final double? averageScore;
  final int? totalNumberOfTurns;

  const _SessionSummaryDTO({
    required this.id,
    required this.scenario,
    this.lastUpdated,
    this.averageScore,
    this.totalNumberOfTurns,
  });

  factory _SessionSummaryDTO.fromJson(Map<String, dynamic> json) {
    return _SessionSummaryDTO(
      id: _string(json['id']) ?? '',
      scenario: _string(json['scenario']) ?? '',
      lastUpdated: _intOrNull(json['lastUpdated'] ?? json['last_updated']),
      averageScore: _doubleOrNull(json['averageScore'] ?? json['average_score']),
      totalNumberOfTurns:
          _intOrNull(json['totalNumberOfTurns'] ?? json['total_number_of_turns']),
    );
  }

  PracticeSessionSummary toDomain() {
    return PracticeSessionSummary(
      id: id,
      scenario: scenario,
      lastUpdated: lastUpdated == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastUpdated!),
      averageScore: averageScore,
      totalTurns: totalNumberOfTurns,
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _intOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _doubleOrNull(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
