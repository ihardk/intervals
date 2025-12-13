import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/streaks_table.dart';

part 'streaks_dao.g.dart';

/// Data Access Object for Streaks table
/// Manages user consistency and streak tracking
@DriftAccessor(tables: [Streaks])
class StreaksDao extends DatabaseAccessor<AppDatabase> with _$StreaksDaoMixin {
  StreaksDao(super.db);

  /// Get a streak by ID
  Future<StreakData?> getStreakById(String id) {
    return (select(streaks)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Get current active streak by type
  Future<StreakData?> getActiveStreak(String streakType) {
    return (select(streaks)
          ..where((s) => s.streakType.equals(streakType))
          ..where((s) => s.isActive.equals(1))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get all active streaks
  Future<List<StreakData>> getActiveStreaks() {
    return (select(streaks)
          ..where((s) => s.isActive.equals(1))
          ..orderBy([(s) => OrderingTerm.desc(s.currentCount)]))
        .get();
  }

  /// Get all streaks by type
  Future<List<StreakData>> getStreaksByType(String streakType) {
    return (select(streaks)
          ..where((s) => s.streakType.equals(streakType))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
        .get();
  }

  /// Get best streak count by type
  Future<int> getBestStreakCount(String streakType) async {
    final streaksList = await (select(streaks)
          ..where((s) => s.streakType.equals(streakType))
          ..orderBy([(s) => OrderingTerm.desc(s.bestCount)])
          ..limit(1))
        .get();

    return streaksList.isEmpty ? 0 : streaksList.first.bestCount;
  }

  /// Get current streak count by type
  Future<int> getCurrentStreakCount(String streakType) async {
    final activeStreak = await getActiveStreak(streakType);
    return activeStreak?.currentCount ?? 0;
  }

  /// Check if streak is active
  Future<bool> isStreakActive(String streakType) async {
    final activeStreak = await getActiveStreak(streakType);
    return activeStreak != null;
  }

  /// Insert a new streak
  Future<int> insertStreak(StreaksCompanion streak) {
    return into(streaks).insert(streak);
  }

  /// Update a streak
  Future<bool> updateStreak(StreakData streak) {
    return update(streaks).replace(streak);
  }

  /// Increment streak count
  Future<int> incrementStreak(String id) async {
    final streak = await getStreakById(id);
    if (streak == null) return 0;

    final newCount = streak.currentCount + 1;
    final newBest = newCount > streak.bestCount ? newCount : streak.bestCount;

    return (update(streaks)..where((s) => s.id.equals(id))).write(
      StreaksCompanion(
        currentCount: Value(newCount),
        bestCount: Value(newBest),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Break a streak
  Future<int> breakStreak(String id) {
    final now = DateTime.now();
    final endDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return (update(streaks)..where((s) => s.id.equals(id))).write(
      StreaksCompanion(
        isActive: const Value(0),
        endDate: Value(endDate),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Reset current count
  Future<int> resetCurrentCount(String id) {
    return (update(streaks)..where((s) => s.id.equals(id))).write(
      StreaksCompanion(
        currentCount: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Delete a streak
  Future<int> deleteStreak(String id) {
    return (delete(streaks)..where((s) => s.id.equals(id))).go();
  }

  /// Delete all streaks by type
  Future<int> deleteStreaksByType(String streakType) {
    return (delete(streaks)..where((s) => s.streakType.equals(streakType))).go();
  }

  /// Get all streaks
  Future<List<StreakData>> getAllStreaks() {
    return (select(streaks)
          ..orderBy([(s) => OrderingTerm.desc(s.isActive), (s) => OrderingTerm.desc(s.currentCount)]))
        .get();
  }

  /// Watch active streak by type
  Stream<StreakData?> watchActiveStreak(String streakType) {
    return (select(streaks)
          ..where((s) => s.streakType.equals(streakType))
          ..where((s) => s.isActive.equals(1))
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Watch all active streaks
  Stream<List<StreakData>> watchActiveStreaks() {
    return (select(streaks)
          ..where((s) => s.isActive.equals(1))
          ..orderBy([(s) => OrderingTerm.desc(s.currentCount)]))
        .watch();
  }

  /// Watch all streaks
  Stream<List<StreakData>> watchAllStreaks() {
    return (select(streaks)
          ..orderBy([(s) => OrderingTerm.desc(s.isActive), (s) => OrderingTerm.desc(s.currentCount)]))
        .watch();
  }
}
