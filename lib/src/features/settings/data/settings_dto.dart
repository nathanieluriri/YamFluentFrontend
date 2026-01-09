import '../domain/settings_enums.dart';
import '../domain/settings_models.dart';

class SettingsViewDTO {
  final PrimaryGoalsViewDTO? primaryGoals;
  final StudyAvailabilityViewDTO? studyAvailability;
  final ProfilingViewDTO? profiling;
  final NotificationViewDTO? notifications;

  const SettingsViewDTO({
    this.primaryGoals,
    this.studyAvailability,
    this.profiling,
    this.notifications,
  });

  factory SettingsViewDTO.fromJson(Map<String, dynamic> json) {
    return SettingsViewDTO(
      primaryGoals: _asMap(json['primaryGoals']).isEmpty
          ? null
          : PrimaryGoalsViewDTO.fromJson(_asMap(json['primaryGoals'])),
      studyAvailability: _asMap(json['studyAvailability']).isEmpty
          ? null
          : StudyAvailabilityViewDTO.fromJson(
              _asMap(json['studyAvailability']),
            ),
      profiling: _asMap(json['profiling']).isEmpty
          ? null
          : ProfilingViewDTO.fromJson(_asMap(json['profiling'])),
      notifications: _asMap(json['notifications']).isEmpty
          ? null
          : NotificationViewDTO.fromJson(_asMap(json['notifications'])),
    );
  }

  SettingsView toDomain() {
    return SettingsView(
      primaryGoals:
          primaryGoals?.toDomain() ?? const PrimaryGoalsView(goals: []),
      studyAvailability:
          studyAvailability?.toDomain() ?? const StudyAvailabilityView(),
      profiling: profiling?.toDomain() ?? const ProfilingView(),
      notifications: notifications?.toDomain() ??
          const NotificationView(
            preference: PushPreferenceView(enabled: false),
          ),
    );
  }
}

class PrimaryGoalsViewDTO {
  final List<MainGoals> goals;

  const PrimaryGoalsViewDTO({required this.goals});

  factory PrimaryGoalsViewDTO.fromJson(Map<String, dynamic> json) {
    return PrimaryGoalsViewDTO(
      goals: _parseGoals(json['goals']),
    );
  }

  PrimaryGoalsView toDomain() {
    return PrimaryGoalsView(goals: goals);
  }
}

class StudyAvailabilityViewDTO {
  final DailyPracticeTime? dailyPracticeTime;

  const StudyAvailabilityViewDTO({this.dailyPracticeTime});

  factory StudyAvailabilityViewDTO.fromJson(Map<String, dynamic> json) {
    final raw = json['dailyPracticeTime']?.toString();
    return StudyAvailabilityViewDTO(
      dailyPracticeTime: DailyPracticeTime.fromValue(raw),
    );
  }

  StudyAvailabilityView toDomain() {
    return StudyAvailabilityView(dailyPracticeTime: dailyPracticeTime);
  }
}

class ProfilingViewDTO {
  final NativeLanguage? nativeLanguage;
  final CurrentProficiency? currentProficiency;
  final LearnerType? learnerType;

  const ProfilingViewDTO({
    this.nativeLanguage,
    this.currentProficiency,
    this.learnerType,
  });

  factory ProfilingViewDTO.fromJson(Map<String, dynamic> json) {
    return ProfilingViewDTO(
      nativeLanguage: NativeLanguage.fromValue(
        json['nativeLanguage']?.toString(),
      ),
      currentProficiency: CurrentProficiency.fromValue(
        json['currentProficiency']?.toString(),
      ),
      learnerType: LearnerType.fromValue(json['learnerType']?.toString()),
    );
  }

  ProfilingView toDomain() {
    return ProfilingView(
      nativeLanguage: nativeLanguage,
      currentProficiency: currentProficiency,
      learnerType: learnerType,
    );
  }
}

class NotificationViewDTO {
  final PushPreferenceViewDTO preference;
  final DevicePushStateViewDTO? deviceState;
  final DeviceStatus thisDeviceStatus;

  const NotificationViewDTO({
    required this.preference,
    this.deviceState,
    this.thisDeviceStatus = DeviceStatus.disabled,
  });

  factory NotificationViewDTO.fromJson(Map<String, dynamic> json) {
    final deviceStateJson = json['device_state'] ?? json['deviceState'];
    return NotificationViewDTO(
      preference: PushPreferenceViewDTO.fromJson(
        _asMap(json['preference']),
      ),
      deviceState: _asMap(deviceStateJson).isEmpty
          ? null
          : DevicePushStateViewDTO.fromJson(_asMap(deviceStateJson)),
      thisDeviceStatus:
          DeviceStatus.fromValue(json['this_device_status']?.toString()) ??
              DeviceStatus.disabled,
    );
  }

  NotificationView toDomain() {
    return NotificationView(
      preference: preference.toDomain(),
      deviceState: deviceState?.toDomain(),
      thisDeviceStatus: thisDeviceStatus,
    );
  }
}

class PushPreferenceViewDTO {
  final bool enabled;

  const PushPreferenceViewDTO({this.enabled = false});

  factory PushPreferenceViewDTO.fromJson(Map<String, dynamic> json) {
    return PushPreferenceViewDTO(
      enabled: json['enabled'] == true,
    );
  }

  PushPreferenceView toDomain() {
    return PushPreferenceView(enabled: enabled);
  }
}

class DevicePushStateViewDTO {
  final String deviceId;
  final DevicePlatform platform;
  final bool permissionGranted;
  final String? pushToken;
  final DateTime? lastSyncedAt;

  const DevicePushStateViewDTO({
    required this.deviceId,
    required this.platform,
    this.permissionGranted = false,
    this.pushToken,
    this.lastSyncedAt,
  });

  factory DevicePushStateViewDTO.fromJson(Map<String, dynamic> json) {
    return DevicePushStateViewDTO(
      deviceId: json['deviceId']?.toString() ?? '',
      platform: DevicePlatform.fromValue(json['platform']?.toString()) ??
          DevicePlatform.android,
      permissionGranted: json['permissionGranted'] == true,
      pushToken: json['pushToken']?.toString(),
      lastSyncedAt: _parseDate(json['lastSyncedAt']),
    );
  }

  DevicePushStateView toDomain() {
    return DevicePushStateView(
      deviceId: deviceId,
      platform: platform,
      permissionGranted: permissionGranted,
      pushToken: pushToken,
      lastSyncedAt: lastSyncedAt,
    );
  }
}

class SettingsRequestDTO {
  final AccountActionDTO? account;
  final ProfileUpdatesDTO? profileUpdates;
  final NotificationBlockDTO? notifications;

  const SettingsRequestDTO({
    this.account,
    this.profileUpdates,
    this.notifications,
  });

  factory SettingsRequestDTO.fromDomain(SettingsRequest request) {
    return SettingsRequestDTO(
      account:
          request.account == null ? null : AccountActionDTO.fromDomain(request.account!),
      profileUpdates: request.profileUpdates == null
          ? null
          : ProfileUpdatesDTO.fromDomain(request.profileUpdates!),
      notifications: request.notifications == null
          ? null
          : NotificationBlockDTO.fromDomain(request.notifications!),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (account != null) {
      data['account'] = account!.toJson();
    }
    if (profileUpdates != null) {
      data['profile_updates'] = profileUpdates!.toJson();
    }
    if (notifications != null) {
      data['notifications'] = notifications!.toJson();
    }
    return data;
  }
}

class AccountActionDTO {
  final bool deleteAccount;
  final bool resetAccount;

  const AccountActionDTO({
    required this.deleteAccount,
    required this.resetAccount,
  });

  factory AccountActionDTO.fromDomain(AccountAction action) {
    return AccountActionDTO(
      deleteAccount: action.deleteAccount,
      resetAccount: action.resetAccount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delete_account': deleteAccount,
      'reset_account': resetAccount,
    };
  }
}

class ProfileUpdatesDTO {
  final List<MainGoals>? mainGoals;
  final DailyPracticeTime? dailyPracticeTime;
  final NativeLanguage? nativeLanguage;
  final CurrentProficiency? currentProficiency;
  final LearnerType? learnerType;

  const ProfileUpdatesDTO({
    this.mainGoals,
    this.dailyPracticeTime,
    this.nativeLanguage,
    this.currentProficiency,
    this.learnerType,
  });

  factory ProfileUpdatesDTO.fromDomain(ProfileUpdates updates) {
    return ProfileUpdatesDTO(
      mainGoals: updates.mainGoals,
      dailyPracticeTime: updates.dailyPracticeTime,
      nativeLanguage: updates.nativeLanguage,
      currentProficiency: updates.currentProficiency,
      learnerType: updates.learnerType,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (mainGoals != null) {
      data['mainGoals'] = mainGoals!.map((goal) => goal.value).toList();
    }
    if (dailyPracticeTime != null) {
      data['dailyPracticeTime'] = dailyPracticeTime!.value;
    }
    if (nativeLanguage != null) {
      data['nativeLanguage'] = nativeLanguage!.value;
    }
    if (currentProficiency != null) {
      data['currentProficiency'] = currentProficiency!.value;
    }
    if (learnerType != null) {
      data['learnerType'] = learnerType!.value;
    }
    return data;
  }
}

class NotificationBlockDTO {
  final PushPreferenceDTO? preference;
  final DevicePushStateDTO? deviceState;

  const NotificationBlockDTO({this.preference, this.deviceState});

  factory NotificationBlockDTO.fromDomain(NotificationBlock block) {
    return NotificationBlockDTO(
      preference: block.preference == null
          ? null
          : PushPreferenceDTO.fromDomain(block.preference!),
      deviceState: block.deviceState == null
          ? null
          : DevicePushStateDTO.fromDomain(block.deviceState!),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (preference != null) {
      data['preference'] = preference!.toJson();
    }
    if (deviceState != null) {
      data['device_state'] = deviceState!.toJson();
    }
    return data;
  }
}

class PushPreferenceDTO {
  final bool? enabled;

  const PushPreferenceDTO({this.enabled});

  factory PushPreferenceDTO.fromDomain(PushPreference preference) {
    return PushPreferenceDTO(enabled: preference.enabled);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (enabled != null) {
      data['enabled'] = enabled;
    }
    return data;
  }
}

class DevicePushStateDTO {
  final String deviceId;
  final DevicePlatform platform;
  final bool permissionGranted;
  final String? pushToken;
  final DateTime? lastSyncedAt;

  const DevicePushStateDTO({
    required this.deviceId,
    required this.platform,
    this.permissionGranted = false,
    this.pushToken,
    this.lastSyncedAt,
  });

  factory DevicePushStateDTO.fromDomain(DevicePushState state) {
    return DevicePushStateDTO(
      deviceId: state.deviceId,
      platform: state.platform,
      permissionGranted: state.permissionGranted,
      pushToken: state.pushToken,
      lastSyncedAt: state.lastSyncedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'device_id': deviceId,
      'platform': platform.value,
      'permission_granted': permissionGranted,
    };
    if (pushToken != null) {
      data['push_token'] = pushToken;
    }
    if (lastSyncedAt != null) {
      data['last_synced_at'] = lastSyncedAt!.toIso8601String();
    }
    return data;
  }
}

List<MainGoals> _parseGoals(Object? value) {
  if (value is List) {
    return value
        .map((item) => MainGoals.fromValue(item?.toString()))
        .whereType<MainGoals>()
        .toList();
  }
  return const [];
}

Map<String, dynamic> _asMap(Object? json) {
  if (json is Map<String, dynamic>) {
    return json;
  }
  return <String, dynamic>{};
}

DateTime? _parseDate(Object? value) {
  if (value == null) {
    return null;
  }
  final raw = value.toString();
  return DateTime.tryParse(raw);
}
