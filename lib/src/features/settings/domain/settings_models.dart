import 'settings_enums.dart';

class SettingsView {
  final PrimaryGoalsView primaryGoals;
  final StudyAvailabilityView studyAvailability;
  final ProfilingView profiling;
  final NotificationView notifications;

  const SettingsView({
    required this.primaryGoals,
    required this.studyAvailability,
    required this.profiling,
    required this.notifications,
  });

  SettingsView copyWith({
    PrimaryGoalsView? primaryGoals,
    StudyAvailabilityView? studyAvailability,
    ProfilingView? profiling,
    NotificationView? notifications,
  }) {
    return SettingsView(
      primaryGoals: primaryGoals ?? this.primaryGoals,
      studyAvailability: studyAvailability ?? this.studyAvailability,
      profiling: profiling ?? this.profiling,
      notifications: notifications ?? this.notifications,
    );
  }
}

class PrimaryGoalsView {
  final List<MainGoals> goals;

  const PrimaryGoalsView({required this.goals});

  PrimaryGoalsView copyWith({List<MainGoals>? goals}) {
    return PrimaryGoalsView(goals: goals ?? this.goals);
  }
}

class StudyAvailabilityView {
  final DailyPracticeTime? dailyPracticeTime;

  const StudyAvailabilityView({this.dailyPracticeTime});

  StudyAvailabilityView copyWith({DailyPracticeTime? dailyPracticeTime}) {
    return StudyAvailabilityView(
      dailyPracticeTime: dailyPracticeTime ?? this.dailyPracticeTime,
    );
  }
}

class ProfilingView {
  final NativeLanguage? nativeLanguage;
  final CurrentProficiency? currentProficiency;
  final LearnerType? learnerType;

  const ProfilingView({
    this.nativeLanguage,
    this.currentProficiency,
    this.learnerType,
  });

  ProfilingView copyWith({
    NativeLanguage? nativeLanguage,
    CurrentProficiency? currentProficiency,
    LearnerType? learnerType,
  }) {
    return ProfilingView(
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      currentProficiency: currentProficiency ?? this.currentProficiency,
      learnerType: learnerType ?? this.learnerType,
    );
  }
}

class NotificationView {
  final PushPreferenceView preference;
  final DevicePushStateView? deviceState;
  final DeviceStatus thisDeviceStatus;

  const NotificationView({
    required this.preference,
    this.deviceState,
    this.thisDeviceStatus = DeviceStatus.disabled,
  });

  NotificationView copyWith({
    PushPreferenceView? preference,
    DevicePushStateView? deviceState,
    DeviceStatus? thisDeviceStatus,
  }) {
    return NotificationView(
      preference: preference ?? this.preference,
      deviceState: deviceState ?? this.deviceState,
      thisDeviceStatus: thisDeviceStatus ?? this.thisDeviceStatus,
    );
  }
}

class PushPreferenceView {
  final bool enabled;

  const PushPreferenceView({this.enabled = false});

  PushPreferenceView copyWith({bool? enabled}) {
    return PushPreferenceView(enabled: enabled ?? this.enabled);
  }
}

class DevicePushStateView {
  final String deviceId;
  final DevicePlatform platform;
  final bool permissionGranted;
  final String? pushToken;
  final DateTime? lastSyncedAt;

  const DevicePushStateView({
    required this.deviceId,
    required this.platform,
    this.permissionGranted = false,
    this.pushToken,
    this.lastSyncedAt,
  });

  DevicePushStateView copyWith({
    String? deviceId,
    DevicePlatform? platform,
    bool? permissionGranted,
    String? pushToken,
    DateTime? lastSyncedAt,
  }) {
    return DevicePushStateView(
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      pushToken: pushToken ?? this.pushToken,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class SettingsRequest {
  final AccountAction? account;
  final ProfileUpdates? profileUpdates;
  final NotificationBlock? notifications;

  const SettingsRequest({
    this.account,
    this.profileUpdates,
    this.notifications,
  });
}

class AccountAction {
  final bool deleteAccount;
  final bool resetAccount;

  const AccountAction({
    this.deleteAccount = false,
    this.resetAccount = false,
  });
}

class ProfileUpdates {
  final List<MainGoals>? mainGoals;
  final DailyPracticeTime? dailyPracticeTime;
  final NativeLanguage? nativeLanguage;
  final CurrentProficiency? currentProficiency;
  final LearnerType? learnerType;

  const ProfileUpdates({
    this.mainGoals,
    this.dailyPracticeTime,
    this.nativeLanguage,
    this.currentProficiency,
    this.learnerType,
  });
}

class NotificationBlock {
  final PushPreference? preference;
  final DevicePushState? deviceState;

  const NotificationBlock({
    this.preference,
    this.deviceState,
  });
}

class PushPreference {
  final bool? enabled;

  const PushPreference({this.enabled});
}

class DevicePushState {
  final String deviceId;
  final DevicePlatform platform;
  final bool permissionGranted;
  final String? pushToken;
  final DateTime? lastSyncedAt;

  const DevicePushState({
    required this.deviceId,
    required this.platform,
    this.permissionGranted = false,
    this.pushToken,
    this.lastSyncedAt,
  });
}
