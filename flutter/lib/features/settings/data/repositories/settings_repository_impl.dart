import 'package:dartz/dartz.dart';
import '../../../../core/database/daos/settings_dao.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Implementation of SettingsRepository
/// Handles application settings storage and retrieval
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDao settingsDao;

  SettingsRepositoryImpl({required this.settingsDao});

  @override
  Future<Either<Failure, String?>> getSetting(String key) async {
    try {
      final setting = await settingsDao.getSetting(key);
      return Right(setting?.value);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get setting: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> setSetting({
    required String key,
    required String value,
    required String type,
  }) async {
    try {
      await settingsDao.setSetting(key, value, type);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to set setting: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getAllSettings() async {
    try {
      final settingsData = await settingsDao.getAllSettings();
      final settingsMap = <String, String>{};

      for (final setting in settingsData) {
        settingsMap[setting.key] = setting.value;
      }

      return Right(settingsMap);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to get all settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(
    Map<String, ({String value, String type})> settings,
  ) async {
    try {
      await settingsDao.updateSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to update settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> getAppSettings() async {
    try {
      final settingsData = await settingsDao.getAllSettings();
      final settingsMap = <String, String>{};

      for (final setting in settingsData) {
        settingsMap[setting.key] = setting.value;
      }

      final appSettings = AppSettings(
        intervalDuration:
            int.tryParse(settingsMap['interval_duration'] ?? '900000') ??
                900000,
        notificationsEnabled: settingsMap['notifications_enabled'] == 'true',
        voiceEnabled: settingsMap['voice_enabled'] == 'true',
        theme: settingsMap['theme'] ?? 'light',
        dailyReminderTime: settingsMap['daily_reminder_time'] ?? '20:00',
        autoCategorize: settingsMap['auto_categorize'] == 'true',
        onboardingCompleted: settingsMap['onboarding_completed'] == 'true',
        activeHoursStart:
            int.tryParse(settingsMap['active_hours_start'] ?? '9') ?? 9,
        activeHoursEnd:
            int.tryParse(settingsMap['active_hours_end'] ?? '21') ?? 21,
      );

      return Right(appSettings);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to get app settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> setIntervalDuration(int durationMs) async {
    return setSetting(
      key: 'interval_duration',
      value: durationMs.toString(),
      type: 'int',
    );
  }

  @override
  Future<Either<Failure, void>> setNotificationsEnabled(bool enabled) async {
    return setSetting(
      key: 'notifications_enabled',
      value: enabled.toString(),
      type: 'boolean',
    );
  }

  @override
  Future<Either<Failure, void>> setVoiceEnabled(bool enabled) async {
    return setSetting(
      key: 'voice_enabled',
      value: enabled.toString(),
      type: 'boolean',
    );
  }

  @override
  Future<Either<Failure, void>> setTheme(String theme) async {
    return setSetting(
      key: 'theme',
      value: theme,
      type: 'string',
    );
  }

  @override
  Future<Either<Failure, void>> setDailyReminderTime(String time) async {
    return setSetting(
      key: 'daily_reminder_time',
      value: time,
      type: 'string',
    );
  }

  @override
  Future<Either<Failure, void>> setAutoCategorize(bool enabled) async {
    return setSetting(
      key: 'auto_categorize',
      value: enabled.toString(),
      type: 'boolean',
    );
  }

  @override
  Future<Either<Failure, void>> setOnboardingCompleted(bool completed) async {
    return setSetting(
      key: 'onboarding_completed',
      value: completed.toString(),
      type: 'boolean',
    );
  }

  @override
  Future<Either<Failure, void>> setActiveHoursStart(int hour) async {
    return setSetting(
      key: 'active_hours_start',
      value: hour.toString(),
      type: 'int',
    );
  }

  @override
  Future<Either<Failure, void>> setActiveHoursEnd(int hour) async {
    return setSetting(
      key: 'active_hours_end',
      value: hour.toString(),
      type: 'int',
    );
  }

  @override
  Stream<Either<Failure, AppSettings>> watchSettings() {
    try {
      return settingsDao.watchAllSettings().asyncMap(
        (settingsData) async {
          final settingsMap = <String, String>{};

          for (final setting in settingsData) {
            settingsMap[setting.key] = setting.value;
          }

          return Right(AppSettings(
            intervalDuration:
                int.tryParse(settingsMap['interval_duration'] ?? '900000') ??
                    900000,
            notificationsEnabled:
                settingsMap['notifications_enabled'] == 'true',
            voiceEnabled: settingsMap['voice_enabled'] == 'true',
            theme: settingsMap['theme'] ?? 'light',
            dailyReminderTime: settingsMap['daily_reminder_time'] ?? '20:00',
            autoCategorize: settingsMap['auto_categorize'] == 'true',
            onboardingCompleted: settingsMap['onboarding_completed'] == 'true',
            activeHoursStart:
                int.tryParse(settingsMap['active_hours_start'] ?? '9') ?? 9,
            activeHoursEnd:
                int.tryParse(settingsMap['active_hours_end'] ?? '21') ?? 21,
          ));
        },
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch settings: ${e.toString()}')),
      );
    }
  }
}
