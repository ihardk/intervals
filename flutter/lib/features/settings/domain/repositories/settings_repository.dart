import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_settings.dart';

/// Repository interface for Settings operations
/// Manages application settings and preferences
abstract class SettingsRepository {
  /// Get a specific setting by key
  Future<Either<Failure, String?>> getSetting(String key);

  /// Set a setting value
  Future<Either<Failure, void>> setSetting({
    required String key,
    required String value,
    required String type,
  });

  /// Get all settings
  Future<Either<Failure, Map<String, String>>> getAllSettings();

  /// Update multiple settings at once
  Future<Either<Failure, void>> updateSettings(
    Map<String, ({String value, String type})> settings,
  );

  /// Get settings as a domain entity
  Future<Either<Failure, AppSettings>> getAppSettings();

  /// Update interval duration
  Future<Either<Failure, void>> setIntervalDuration(int durationMs);

  /// Toggle notifications on/off
  Future<Either<Failure, void>> setNotificationsEnabled(bool enabled);

  /// Toggle voice input on/off
  Future<Either<Failure, void>> setVoiceEnabled(bool enabled);

  /// Set theme (dark/light)
  Future<Either<Failure, void>> setTheme(String theme);

  /// Set daily reminder time
  Future<Either<Failure, void>> setDailyReminderTime(String time);

  /// Toggle auto-categorization
  Future<Either<Failure, void>> setAutoCategorize(bool enabled);

  /// Mark onboarding as completed
  Future<Either<Failure, void>> setOnboardingCompleted(bool completed);

  /// Set active hours start time (0-23)
  Future<Either<Failure, void>> setActiveHoursStart(int hour);

  /// Set active hours end time (0-23)
  Future<Either<Failure, void>> setActiveHoursEnd(int hour);

  /// Watch settings changes (reactive stream)
  Stream<Either<Failure, AppSettings>> watchSettings();
}
