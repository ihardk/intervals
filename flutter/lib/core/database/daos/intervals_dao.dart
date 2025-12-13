import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/intervals_table.dart';

part 'intervals_dao.g.dart';

/// Data Access Object for Intervals table
/// Tracks notification intervals and user responses
@DriftAccessor(tables: [Intervals])
class IntervalsDao extends DatabaseAccessor<AppDatabase> with _$IntervalsDaoMixin {
  IntervalsDao(super.db);

  /// Get an interval by ID
  Future<IntervalData?> getIntervalById(String id) {
    return (select(intervals)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  /// Get the next upcoming interval
  Future<IntervalData?> getNextInterval() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(intervals)
          ..where((i) => i.scheduledTime.isBiggerThanValue(now))
          ..where((i) => i.isCompleted.equals(0))
          ..orderBy([(i) => OrderingTerm.asc(i.scheduledTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get intervals for a date range
  Future<List<IntervalData>> getIntervalsByDateRange(int startTimestamp, int endTimestamp) {
    return (select(intervals)
          ..where((i) => i.scheduledTime.isBetweenValues(startTimestamp, endTimestamp))
          ..orderBy([(i) => OrderingTerm.desc(i.scheduledTime)]))
        .get();
  }

  /// Get today's intervals
  Future<List<IntervalData>> getTodayIntervals() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000;

    return (select(intervals)
          ..where((i) => i.scheduledTime.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([(i) => OrderingTerm.desc(i.scheduledTime)]))
        .get();
  }

  /// Get completed intervals for today
  Future<List<IntervalData>> getTodayCompletedIntervals() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000;

    return (select(intervals)
          ..where((i) => i.scheduledTime.isBetweenValues(startOfDay, endOfDay))
          ..where((i) => i.isCompleted.equals(1))
          ..orderBy([(i) => OrderingTerm.desc(i.scheduledTime)]))
        .get();
  }

  /// Get intervals by response type
  Future<List<IntervalData>> getIntervalsByResponseType(String responseType) {
    return (select(intervals)
          ..where((i) => i.responseType.equals(responseType))
          ..orderBy([(i) => OrderingTerm.desc(i.scheduledTime)]))
        .get();
  }

  /// Calculate completion rate for a date
  Future<double> getCompletionRate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000;

    final totalIntervals = await (select(intervals)
          ..where((i) => i.scheduledTime.isBetweenValues(startOfDay, endOfDay)))
        .get();

    if (totalIntervals.isEmpty) return 0.0;

    final completedCount = totalIntervals.where((i) => i.responseType == 'logged').length;
    return completedCount / totalIntervals.length;
  }

  /// Get skipped intervals count for a time period
  Future<int> getSkippedCount(int startTimestamp, int endTimestamp) async {
    final skipped = await (select(intervals)
          ..where((i) => i.scheduledTime.isBetweenValues(startTimestamp, endTimestamp))
          ..where((i) => i.responseType.equals('skipped')))
        .get();

    return skipped.length;
  }

  /// Get recent skipped intervals count
  Future<int> getRecentSkippedCount(int hours) async {
    final cutoffTime = DateTime.now()
        .subtract(Duration(hours: hours))
        .millisecondsSinceEpoch;

    final skipped = await (select(intervals)
          ..where((i) => i.scheduledTime.isBiggerThanValue(cutoffTime))
          ..where((i) => i.responseType.equals('skipped')))
        .get();

    return skipped.length;
  }

  /// Insert a new interval
  Future<int> insertInterval(IntervalsCompanion interval) {
    return into(intervals).insert(interval);
  }

  /// Update an interval
  Future<bool> updateInterval(IntervalData interval) {
    return update(intervals).replace(interval);
  }

  /// Complete an interval with response
  Future<int> completeInterval({
    required String id,
    required String responseType,
    required int responseTime,
    String? logId,
  }) {
    return (update(intervals)..where((i) => i.id.equals(id))).write(
      IntervalsCompanion(
        responseType: Value(responseType),
        responseTime: Value(responseTime),
        logId: Value(logId),
        isCompleted: const Value(1),
      ),
    );
  }

  /// Delete intervals older than specified days
  Future<int> purgeOldIntervals(int olderThanDays) {
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: olderThanDays))
        .millisecondsSinceEpoch;

    return (delete(intervals)
          ..where((i) => i.scheduledTime.isSmallerThanValue(cutoffTime)))
        .go();
  }

  /// Watch upcoming intervals
  Stream<List<IntervalData>> watchUpcomingIntervals() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(intervals)
          ..where((i) => i.scheduledTime.isBiggerThanValue(now))
          ..where((i) => i.isCompleted.equals(0))
          ..orderBy([(i) => OrderingTerm.asc(i.scheduledTime)]))
        .watch();
  }

  /// Watch today's intervals
  Stream<List<IntervalData>> watchTodayIntervals() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000;

    return (select(intervals)
          ..where((i) => i.scheduledTime.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([(i) => OrderingTerm.desc(i.scheduledTime)]))
        .watch();
  }
}
