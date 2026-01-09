T? enumFromValue<T>(
  List<T> values,
  String? raw,
  String Function(T) valueSelector,
) {
  if (raw == null) {
    return null;
  }
  final normalized = raw.trim();
  for (final value in values) {
    if (valueSelector(value).trim() == normalized) {
      return value;
    }
  }
  return null;
}

enum MainGoals {
  travel('Travel'),
  business('Business'),
  academic('Academic'),
  everydayConversations('Everyday Conversations'),
  soundMorePolite('Sound More Polite'),
  soundClearer('Sound Clearer'),
  reduceHesitation('Reduce Hesitation'),
  improvePronunciation('Improve Pronunciation'),
  succeedInJobInterviews('Succeed in Job Interviews'),
  soundMoreNatural('Sound More Natural'),
  stopTranslatingInMyHead('Stop Translating in My Head');

  final String value;

  const MainGoals(this.value);

  static MainGoals? fromValue(String? value) {
    return enumFromValue(MainGoals.values, value, (item) => item.value);
  }

  String get label => value.trim();
}

enum DailyPracticeTime {
  mins5('5 mins'),
  mins10('10 mins'),
  mins12('12 mins'),
  mins15('15 mins'),
  mins20('20 mins');

  final String value;

  const DailyPracticeTime(this.value);

  static DailyPracticeTime? fromValue(String? value) {
    return enumFromValue(DailyPracticeTime.values, value, (item) => item.value);
  }

  String get label => value.trim();
}

enum NativeLanguage {
  arabic('Arabic (العربية)'),
  bengali('Bengali (বাংলা)'),
  chinese('Chinese (中文)'),
  czech('Czech (Čeština)'),
  dutch('Dutch (Nederlands)'),
  english('English (English)'),
  filipino('Filipino (Filipino)'),
  finnish('Finnish (Suomi)'),
  french('French (Français)'),
  german('German (Deutsch)'),
  greek('Greek (Ελληνικά)'),
  hausa('Hausa (Hausa)'),
  hindi('Hindi (हिन्दी)'),
  igbo('Igbo (Igbo)'),
  italian('Italian (Italiano)'),
  japanese('Japanese (日本語)'),
  korean('Korean (한국어)'),
  malay('Malay (Bahasa Melayu)'),
  persian('Persian (فارسی)'),
  polish('Polish (Polski)'),
  portuguese('Portuguese (Português)'),
  romanian('Romanian (Română)'),
  russian('Russian (Русский)'),
  spanish('Spanish (Español)'),
  swahili('Swahili (Kiswahili)'),
  swedish('Swedish (Svenska)'),
  thai('Thai (ไทย)'),
  turkish('Turkish (Türkçe)'),
  ukrainian('Ukrainian (Українська)'),
  vietnamese('Vietnamese (Tiếng Việt)'),
  yoruba('Yoruba (Yorùbá)');

  final String value;

  const NativeLanguage(this.value);

  static NativeLanguage? fromValue(String? value) {
    return enumFromValue(NativeLanguage.values, value, (item) => item.value);
  }

  String get label => value.trim();
}

enum CurrentProficiency {
  beginner(
    '[https://res.cloudinary.com/dloh0ffv3/image/upload/v1767333942/begginer_current_proficiency_a7bbpe.png] (BEGINNER) I know basic words and phrases. ',
  ),
  intermediate(
    '[https://res.cloudinary.com/dloh0ffv3/image/upload/v1767333942/intermediate_current_proficiency_fhwou3.png] (INTERMEDIATE) I can hold everyday conversation.',
  ),
  advanced(
    '[https://res.cloudinary.com/dloh0ffv3/image/upload/v1767333942/advanced_current_proficiency_y0usq8.png] (ADVANCED) I speak confidently and fluently.',
  );

  final String value;

  const CurrentProficiency(this.value);

  static CurrentProficiency? fromValue(String? value) {
    return enumFromValue(
      CurrentProficiency.values,
      value,
      (item) => item.value,
    );
  }

  String get label => value.trim();
}

enum LearnerType {
  speakingFirst(
    '[https://res.cloudinary.com/dloh0ffv3/image/upload/v1767333942/Speaking_first_learner_type_xy4js2.png] (Speaking-first learner) I prefer to speak as much as possible.  ',
  ),
  visual(
    '[https://res.cloudinary.com/dloh0ffv3/image/upload/v1767333942/Visual_learner_type_q2q4zn.png] (Visual learner) I learn better with images and examples.',
  ),
  shortBurst(
    ' [https://res.cloudinary.com/dloh0ffv3/image/upload/v1767333942/Short_burst_learner_type_agw8xv.png] (Short-burst learner) I like quick, focused practice sessions.',
  ),
  structured(
    '[https://res.cloudinary.com/dloh0ffv3/image/upload/v1767333942/Structural_learner_type_nbarte.png] (Structured learner) I prefer step-by-step lessons.',
  );

  final String value;

  const LearnerType(this.value);

  static LearnerType? fromValue(String? value) {
    return enumFromValue(LearnerType.values, value, (item) => item.value);
  }

  String get label => value.trim();
}

enum DevicePlatform {
  ios('ios'),
  android('android'),
  web('web');

  final String value;

  const DevicePlatform(this.value);

  static DevicePlatform? fromValue(String? value) {
    return enumFromValue(DevicePlatform.values, value, (item) => item.value);
  }
}

enum DeviceStatus {
  enabled('enabled'),
  needsSetup('needs_setup'),
  disabled('disabled');

  final String value;

  const DeviceStatus(this.value);

  static DeviceStatus? fromValue(String? value) {
    return enumFromValue(DeviceStatus.values, value, (item) => item.value);
  }
}
