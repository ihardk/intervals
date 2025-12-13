import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/logs_table.dart';

part 'logs_dao.g.dart';

/// Data Access Object for Logs table
/// Provides type-safe database operations for log entries
@DriftAccessor(tables: [Logs])
class LogsDao extends DatabaseAccessor<AppDatabase> with _$LogsDaoMixin {
  LogsDao(super.db);

  /// Get a log by ID
  Future<LogData?> getLogById(String id) {
    return (select(logs)..where((log) => log.id.equals(id))).getSingleOrNull();
  }

  /// Get today's logs
  Future<List<LogData>> getTodayLogs() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000; // 24 hours in milliseconds

    return (select(logs)
          ..where((log) => log.timestamp.isBetweenValues(startOfDay, endOfDay))
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]))
        .get();
  }

  /// Get logs for a date range
  Future<List<LogData>> getLogsByDateRange(int startTimestamp, int endTimestamp) {
    return (select(logs)
          ..where((log) => log.timestamp.isBetweenValues(startTimestamp, endTimestamp))
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]))
        .get();
  }

  /// Get logs by category
  Future<List<LogData>> getLogsByCategory(String category) {
    return (select(logs)
          ..where((log) => log.category.equals(category))
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]))
        .get();
  }

  /// Get logs by transcription status
  Future<List<LogData>> getLogsByTranscriptionStatus(String status) {
    return (select(logs)
          ..where((log) => log.transcriptionStatus.equals(status))
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]))
        .get();
  }

  /// Search logs by content
  Future<List<LogData>> searchLogs(String query, {int limit = 50}) {
    return (select(logs)
          ..where((log) => log.content.contains(query))
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)])
          ..limit(limit))
        .get();
  }

  /// Get all logs (paginated)
  Future<List<LogData>> getAllLogs({int offset = 0, int limit = 50}) {
    return (select(logs)
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get logs count
  Future<int> getLogsCount() async {
    final countExp = logs.id.count();
    final query = selectOnly(logs)
      ..addColumns([countExp])
      ..where(logs.isDeleted.equals(0));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get logs count by entry type
  Future<int> getLogsCountByType(String entryType) async {
    final countExp = logs.id.count();
    final query = selectOnly(logs)
      ..addColumns([countExp])
      ..where(logs.entryType.equals(entryType))
      ..where(logs.isDeleted.equals(0));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get logs count for today
  Future<int> getTodayLogsCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000;

    final countExp = logs.id.count();
    final query = selectOnly(logs)
      ..addColumns([countExp])
      ..where(logs.timestamp.isBetweenValues(startOfDay, endOfDay))
      ..where(logs.isDeleted.equals(0));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get logs by hour of day
  Future<Map<int, int>> getLogsByHour() async {
    final allLogs = await (select(logs)..where((log) => log.isDeleted.equals(0))).get();

    final distribution = <int, int>{};
    for (final log in allLogs) {
      final hour = DateTime.fromMillisecondsSinceEpoch(log.timestamp).hour;
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }

    return distribution;
  }

  /// Insert a new log
  Future<int> insertLog(LogsCompanion log) {
    return into(logs).insert(log);
  }

  /// Update an existing log
  Future<bool> updateLog(LogData log) {
    return update(logs).replace(log);
  }

  /// Soft delete a log
  Future<int> softDeleteLog(String id) {
    return (update(logs)..where((log) => log.id.equals(id))).write(
      LogsCompanion(
        isDeleted: const Value(1),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Hard delete a log (permanent)
  Future<int> hardDeleteLog(String id) {
    return (delete(logs)..where((log) => log.id.equals(id))).go();
  }

  /// Delete a log (alias for hard delete for API compatibility)
  Future<int> deleteLog(String id) {
    return hardDeleteLog(id);
  }

  /// Delete multiple logs by IDs
  Future<int> deleteLogsByIds(List<String> ids) {
    return (delete(logs)..where((log) => log.id.isIn(ids))).go();
  }

  /// Delete all logs (use with caution)
  Future<int> deleteAllLogs() {
    return delete(logs).go();
  }

  /// Purge old deleted logs
  Future<int> purgeDeletedLogs(int olderThanDays) {
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: olderThanDays))
        .millisecondsSinceEpoch;

    return (delete(logs)
          ..where((log) => log.isDeleted.equals(1))
          ..where((log) => log.updatedAt.isSmallerThanValue(cutoffTime)))
        .go();
  }

  /// Get logs stream for reactive updates (today's logs)
  Stream<List<LogData>> watchTodayLogs() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000;

    return (select(logs)
          ..where((log) => log.timestamp.isBetweenValues(startOfDay, endOfDay))
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]))
        .watch();
  }

  /// Watch all logs (paginated)
  Stream<List<LogData>> watchAllLogs({int limit = 50}) {
    return (select(logs)
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)])
          ..limit(limit))
        .watch();
  }

  /// Watch logs by category
  Stream<List<LogData>> watchLogsByCategory(String category) {
    return (select(logs)
          ..where((log) => log.category.equals(category))
          ..where((log) => log.isDeleted.equals(0))
          ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]))
        .watch();
  }
}
