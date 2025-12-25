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
  /// Uses the same slot calculation logic as notification scheduler
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

    // Create a set of existing log timestamps (with tolerance for timing differences)
    final existingTimestamps = <int>{};
    for (final log in existingLogs) {
      existingTimestamps.add(log.timestamp);
    }

    // Calculate expected notification slots using same logic as notification scheduler
    final expectedSlots = _calculateExpectedSlots(
      startTime: startTime,
      endTime: endTime,
      intervalDurationMs: intervalDurationMs,
      activeHoursStart: activeHoursStart,
      activeHoursEnd: activeHoursEnd,
    );

    // Find slots that don't have corresponding logs
    for (final slot in expectedSlots) {
      final slotTimestamp = slot.millisecondsSinceEpoch;

      // Check if a log exists within +/- 2 minutes of this slot
      // This tolerance handles slight timing differences
      final tolerance = 2 * 60 * 1000; // 2 minutes in milliseconds
      final hasLog = existingTimestamps.any((timestamp) =>
          (timestamp - slotTimestamp).abs() < tolerance);

      if (!hasLog) {
        // Create a skipped entry for this slot
        await logRepository.createLog(
          content: 'Skipped',
          entryType: 'skipped',
          timestamp: slotTimestamp,
        );
        print(
            'SkippedIntervalService: Created skipped entry at ${slot.toIso8601String()}');
      }
    }
  }

  /// Calculate expected notification slots using same logic as notification scheduler
  /// This ensures perfect alignment between backfilled logs and notification schedule
  List<DateTime> _calculateExpectedSlots({
    required DateTime startTime,
    required DateTime endTime,
    required int intervalDurationMs,
    required int activeHoursStart,
    required int activeHoursEnd,
  }) {
    final List<DateTime> slots = [];

    // Iterate through each day from startTime to endTime
    var currentDate = DateTime(startTime.year, startTime.month, startTime.day);
    final endDate = DateTime(endTime.year, endTime.month, endTime.day);

    while (!currentDate.isAfter(endDate)) {
      // For each day, calculate slots starting from activeHoursStart
      final dayStartTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        activeHoursStart,
        0,
      );

      // First slot is at dayStartTime + interval
      var currentSlot =
          dayStartTime.add(Duration(milliseconds: intervalDurationMs));

      // Generate slots for this day
      int loopLimit = 0;
      while (loopLimit < 1000) {
        loopLimit++;

        // Check if slot is within active hours
        if (!_isActive(currentSlot.hour, activeHoursStart, activeHoursEnd)) {
          break; // End of active window for this day
        }

        // Only include slots that are:
        // 1. After the startTime (last log time)
        // 2. Before endTime (now)
        if (currentSlot.isAfter(startTime) && currentSlot.isBefore(endTime)) {
          slots.add(currentSlot);
        }

        // Move to next slot
        currentSlot = currentSlot.add(Duration(milliseconds: intervalDurationMs));
      }

      // Move to next day
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return slots;
  }

  /// Check if hour is within active window
  bool _isActive(int hour, int start, int end) {
    if (start <= end) {
      return hour >= start && hour < end;
    } else {
      // Crossing midnight (e.g., 21 to 9)
      return hour >= start || hour < end;
    }
  }
}
