import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/daos/logs_dao.dart';
import '../../../../core/database/daos/settings_dao.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/log_repository.dart';

/// Service to detect and backfill skipped intervals
/// Called on app startup to ensure missed intervals are recorded
class SkippedIntervalService {
  final LogsDao logsDao;
  final SettingsDao settingsDao;
  final LogRepository logRepository;

  SkippedIntervalService({
    required this.logsDao,
    required this.settingsDao,
    required this.logRepository,
  });

  /// Backfill skipped intervals from last log to now
  /// Should be called on app startup
  Future<void> backfillSkippedIntervals() async {
    try {
      // Get settings
      final intervalSetting =
          await settingsDao.getSetting(AppConstants.keyIntervalDuration);
      final activeHoursStartSetting =
          await settingsDao.getSetting('active_hours_start');
      final activeHoursEndSetting =
          await settingsDao.getSetting('active_hours_end');

      if (intervalSetting == null) return;

      final intervalDurationMs =
          int.tryParse(intervalSetting.value) ?? (30 * 60 * 1000);
      final activeHoursStart =
          int.tryParse(activeHoursStartSetting?.value ?? '8') ?? 8;
      final activeHoursEnd =
          int.tryParse(activeHoursEndSetting?.value ?? '22') ?? 22;

      // Get the most recent non-skipped log
      final lastLog = await _getLastNonSkippedLog();
      if (lastLog == null) return; // No logs yet, nothing to backfill

      final lastLogTime =
          DateTime.fromMillisecondsSinceEpoch(lastLog.timestamp);
      final now = DateTime.now();

      // Don't backfill if last log was very recent
      if (now.difference(lastLogTime).inMilliseconds < intervalDurationMs)
        return;

      // Calculate missed intervals across days
      await _backfillBetweenTimes(
        startTime: lastLogTime,
        endTime: now,
        intervalDurationMs: intervalDurationMs,
        activeHoursStart: activeHoursStart,
        activeHoursEnd: activeHoursEnd,
      );
    } catch (e) {
      print('SkippedIntervalService: Error backfilling: $e');
    }
  }

  /// Get the last log that is not of type 'skipped'
  Future<LogData?> _getLastNonSkippedLog() async {
    // Get all recent logs to find the last non-skipped one
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentLogs = await logsDao.getLogsByDateRange(
      thirtyDaysAgo.millisecondsSinceEpoch,
      now.millisecondsSinceEpoch,
    );

    // Sort by timestamp descending and find first non-skipped
    recentLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    for (final log in recentLogs) {
      if (log.entryType != 'skipped') {
        return log;
      }
    }
    return null;
  }

  /// Backfill skipped entries between two times
  Future<void> _backfillBetweenTimes({
    required DateTime startTime,
    required DateTime endTime,
    required int intervalDurationMs,
    required int activeHoursStart,
    required int activeHoursEnd,
  }) async {
    // Get all existing logs in the time range to avoid duplicates
    final existingLogs = await logsDao.getLogsByDateRange(
      startTime.millisecondsSinceEpoch,
      endTime.millisecondsSinceEpoch,
    );

    // Create a set of existing log timestamps (rounded to nearest interval)
    final existingTimestamps = <int>{};
    for (final log in existingLogs) {
      // Round to nearest interval to handle slight time differences
      final roundedTs =
          (log.timestamp ~/ intervalDurationMs) * intervalDurationMs;
      existingTimestamps.add(roundedTs);
    }

    // Start from the next interval after last log
    var currentTime = startTime.add(Duration(milliseconds: intervalDurationMs));

    while (currentTime.isBefore(endTime)) {
      // Check if within active hours for this day
      if (currentTime.hour >= activeHoursStart &&
          currentTime.hour < activeHoursEnd) {
        // Check if a log already exists for this interval
        final roundedCurrentTs =
            (currentTime.millisecondsSinceEpoch ~/ intervalDurationMs) *
                intervalDurationMs;
        if (!existingTimestamps.contains(roundedCurrentTs)) {
          // Create a skipped entry for this interval
          await logRepository.createLog(
            content: 'Skipped',
            entryType: 'skipped',
            timestamp: currentTime.millisecondsSinceEpoch,
          );
          print(
              'SkippedIntervalService: Created skipped entry at ${currentTime.toIso8601String()}');
        } else {
          print(
              'SkippedIntervalService: Log already exists for ${currentTime.toIso8601String()}, skipping');
        }
      }

      // Move to next interval
      currentTime = currentTime.add(Duration(milliseconds: intervalDurationMs));
    }
  }
}
