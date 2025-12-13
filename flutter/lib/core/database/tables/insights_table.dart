import 'package:drift/drift.dart';

/// Insights table - stores pre-computed insights and analytics
@DataClassName('InsightData')
class Insights extends Table {
  /// Primary key - UUID v4
  TextColumn get id => text()();

  /// Insight type: 'daily', 'weekly', 'monthly', or 'pattern'
  TextColumn get insightType => text()();

  /// Reference date (ISO date YYYY-MM-DD)
  TextColumn get date => text()();

  /// JSON insight data
  TextColumn get data => text()();

  /// Creation timestamp
  IntColumn get createdAt => integer()();

  /// Optional cache expiration timestamp
  IntColumn get expiresAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
