import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/onboarding_draft.dart';
import 'onboarding_options_dto.dart';

abstract class OnboardingRemoteDataSource {
  Future<OnboardingOptionsDTO> getOptions();
  Future<void> completeOnboarding(OnboardingDraft draft);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final Dio _dio;

  OnboardingRemoteDataSourceImpl(this._dio);

  @override
  Future<OnboardingOptionsDTO> getOptions() async {
    final response = await _dio.get('/v1/users/onboarding/options');
    final api = APIResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => OnboardingOptionsDTO.fromJson(_asMap(json)),
    );
    if (api.data == null) {
      throw StateError('Missing onboarding options');
    }
    return api.data!;
  }

  @override
  Future<void> completeOnboarding(OnboardingDraft draft) async {
    final payload = {
      'userPersonalProfilingData': {
        'nativeLanguage': draft.nativeLanguage,
        'currentProficiency': draft.currentProficiency,
        'mainGoals': draft.mainGoals,
        'learnerType': draft.learnerType,
        'dailyPracticeTime': draft.dailyPracticeTime,
      },
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
    debugPrint('Onboarding payload: $payload');
    await _dio.patch('/v1/users/onboard/complete', data: payload);
  }

  Map<String, dynamic> _asMap(Object? json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    return <String, dynamic>{};
  }
}

final onboardingRemoteDataSourceProvider = Provider<OnboardingRemoteDataSource>((ref) {
  return OnboardingRemoteDataSourceImpl(ref.watch(dioProvider));
});
