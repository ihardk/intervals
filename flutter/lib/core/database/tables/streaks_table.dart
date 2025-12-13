import 'package:drift/drift.dart';

/// Streaks table - tracks user consistency and streaks
@DataClassName('StreakData')
class Streaks extends Table {
  /// Primary key - UUID v4
  TextColumn get id => text()();

  /// Streak type: 'daily_logs', 'consistent_intervals', or 'no_skip'
  TextColumn get streakType => text()();

  /// Start date (ISO date YYYY-MM-DD)
  TextColumn get startDate => text()();

  /// End date (ISO date YYYY-MM-DD), null if ongoing
  TextColumn get endDate => text().nullable()();

  /// Current count
  IntColumn get currentCount => integer()();

  /// Best count ever achieved
  IntColumn get bestCount => integer()();

  /// Is streak currently active (0 = inactive, 1 = active)
  IntColumn get isActive => integer().withDefault(const Constant(1))();

  /// Creation timestamp
  IntColumn get createdAt => integer()();

  /// Last update timestamp
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
