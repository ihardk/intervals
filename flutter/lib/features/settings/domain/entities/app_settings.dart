import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/intervals.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// Application settings entity
/// Strongly-typed wrapper around the key-value settings store
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    /// Interval duration in milliseconds (900000 or 1800000)
    @Default(IntervalConstants.defaultInterval) int intervalDuration,

    /// Whether notifications are enabled
    @Default(true) bool notificationsEnabled,

    /// Whether voice input is enabled
    @Default(true) bool voiceEnabled,

    /// App theme ('dark' or 'light')
    @Default('dark') String theme,

    /// Daily reminder time (HH:MM format)
    @Default('20:00') String dailyReminderTime,

    /// Whether to auto-categorize logs
    @Default(true) bool autoCategorize,

    /// Whether onboarding has been completed
    @Default(false) bool onboardingCompleted,

    /// Start of active hours (0-23)
    @Default(9) int activeHoursStart,

    /// End of active hours (0-23)
    @Default(21) int activeHoursEnd,
  }) = _AppSettings;

  const AppSettings._();

  /// Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  /// Get interval duration in minutes
  int get intervalDurationMinutes => intervalDuration ~/ 60000;

  /// Check if using 15 minute intervals
  bool get isFifteenMinuteInterval =>
      intervalDuration == IntervalConstants.fifteenMinutes;

  /// Check if using 30 minute intervals
  bool get isThirtyMinuteInterval =>
      intervalDuration == IntervalConstants.thirtyMinutes;
}

/// Setting type enumeration
enum SettingType {
  @JsonValue('string')
  string,
  @JsonValue('number')
  number,
  @JsonValue('boolean')
  boolean,
  @JsonValue('json')
  json,
}

/// Individual setting (for key-value storage)
@freezed
class Setting with _$Setting {
  const factory Setting({
    required String key,
    required String value,
    required SettingType type,
    required int updatedAt,
  }) = _Setting;

  const Setting._();

  /// Parse boolean value
  bool get boolValue => value.toLowerCase() == 'true';

  /// Parse number value
  num get numValue => num.parse(value);

  /// Parse integer value
  int get intValue => int.parse(value);

  /// Parse double value
  double get doubleValue => double.parse(value);
}
