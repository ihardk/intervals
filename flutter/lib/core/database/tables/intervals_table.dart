import 'package:drift/drift.dart';

/// Intervals table - tracks notification intervals and user responses
@DataClassName('IntervalData')
class Intervals extends Table {
  /// Primary key - UUID v4
  TextColumn get id => text()();

  /// When notification should fire (Unix timestamp in ms)
  IntColumn get scheduledTime => integer()();

  /// When notification actually fired (Unix timestamp in ms)
  IntColumn get actualTime => integer().nullable()();

  /// When user responded (Unix timestamp in ms)
  IntColumn get responseTime => integer().nullable()();

  /// Response type: 'logged', 'skipped', or 'ignored'
  TextColumn get responseType => text().nullable()();

  /// Foreign key to logs.id if logged
  TextColumn get logId => text().nullable()();

  /// Interval duration in milliseconds (900000 or 1800000)
  IntColumn get intervalDuration => integer()();

  /// Whether interval was handled (0 = not completed, 1 = completed)
  IntColumn get isCompleted => integer().withDefault(const Constant(0))();

  /// Creation timestamp
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];
}
