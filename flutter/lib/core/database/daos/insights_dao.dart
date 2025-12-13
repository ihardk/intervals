import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/insights_table.dart';

part 'insights_dao.g.dart';

/// Data Access Object for Insights table
/// Manages pre-computed insights and analytics
@DriftAccessor(tables: [Insights])
class InsightsDao extends DatabaseAccessor<AppDatabase> with _$InsightsDaoMixin {
  InsightsDao(super.db);

  /// Get an insight by ID
  Future<InsightData?> getInsightById(String id) {
    return (select(insights)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  /// Get insight by type and date
  Future<InsightData?> getInsight(String insightType, String date) {
    return (select(insights)
          ..where((i) => i.insightType.equals(insightType))
          ..where((i) => i.date.equals(date)))
        .getSingleOrNull();
  }

  /// Get all insights of a specific type
  Future<List<InsightData>> getInsightsByType(String insightType, {int limit = 30}) {
    return (select(insights)
          ..where((i) => i.insightType.equals(insightType))
          ..orderBy([(i) => OrderingTerm.desc(i.date)])
          ..limit(limit))
        .get();
  }

  /// Get daily insights for a date range
  Future<List<InsightData>> getDailyInsights(String startDate, String endDate) {
    return (select(insights)
          ..where((i) => i.insightType.equals('daily'))
          ..where((i) => i.date.isBetweenValues(startDate, endDate))
          ..orderBy([(i) => OrderingTerm.desc(i.date)]))
        .get();
  }

  /// Get today's insight
  Future<InsightData?> getTodayInsight() {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return (select(insights)
          ..where((i) => i.insightType.equals('daily'))
          ..where((i) => i.date.equals(dateStr)))
        .getSingleOrNull();
  }

  /// Get this week's insight
  Future<InsightData?> getWeeklyInsight() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dateStr = '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}';

    return (select(insights)
          ..where((i) => i.insightType.equals('weekly'))
          ..where((i) => i.date.equals(dateStr)))
        .getSingleOrNull();
  }

  /// Get this month's insight
  Future<InsightData?> getMonthlyInsight() {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    return (select(insights)
          ..where((i) => i.insightType.equals('monthly'))
          ..where((i) => i.date.equals(dateStr)))
        .getSingleOrNull();
  }

  /// Insert or update an insight
  Future<void> upsertInsight(InsightsCompanion insight) {
    return into(insights).insertOnConflictUpdate(insight);
  }

  /// Insert a new insight
  Future<int> insertInsight(InsightsCompanion insight) {
    return into(insights).insert(insight);
  }

  /// Update an insight
  Future<bool> updateInsight(InsightData insight) {
    return update(insights).replace(insight);
  }

  /// Delete an insight
  Future<int> deleteInsight(String id) {
    return (delete(insights)..where((i) => i.id.equals(id))).go();
  }

  /// Delete insights by type
  Future<int> deleteInsightsByType(String insightType) {
    return (delete(insights)..where((i) => i.insightType.equals(insightType))).go();
  }

  /// Delete expired insights
  Future<int> deleteExpiredInsights() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (delete(insights)
          ..where((i) => i.expiresAt.isSmallerThanValue(now)))
        .go();
  }

  /// Get insights count
  Future<int> getInsightsCount() async {
    final countExp = insights.id.count();
    final query = selectOnly(insights)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Watch insight by type and date
  Stream<InsightData?> watchInsight(String insightType, String date) {
    return (select(insights)
          ..where((i) => i.insightType.equals(insightType))
          ..where((i) => i.date.equals(date)))
        .watchSingleOrNull();
  }

  /// Watch insights by type
  Stream<List<InsightData>> watchInsightsByType(String insightType, {int limit = 30}) {
    return (select(insights)
          ..where((i) => i.insightType.equals(insightType))
          ..orderBy([(i) => OrderingTerm.desc(i.date)])
          ..limit(limit))
        .watch();
  }
}
