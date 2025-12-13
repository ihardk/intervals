import 'package:drift/drift.dart';

/// Logs table - stores all user activity log entries
/// Matches the React Native SQLite schema exactly
@DataClassName('LogData')
class Logs extends Table {
  /// Primary key - UUID v4
  TextColumn get id => text()();

  /// Unix timestamp in milliseconds - when activity happened
  IntColumn get timestamp => integer()();

  /// The actual log text content
  TextColumn get content => text()();

  /// Entry type: 'text', 'voice', or 'manual'
  TextColumn get entryType => text()();

  /// Path to audio file (if voice entry)
  TextColumn get audioPath => text().nullable()();

  /// Transcription status: 'pending', 'complete', or 'failed'
  TextColumn get transcriptionStatus =>
      text().withDefault(const Constant('complete'))();

  /// Auto-detected or manual category
  TextColumn get category => text().nullable()();

  /// JSON array of tags
  TextColumn get tags => text().nullable()();

  /// Optional mood indicator
  TextColumn get mood => text().nullable()();

  /// Unix timestamp in milliseconds - creation time
  IntColumn get createdAt => integer()();

  /// Unix timestamp in milliseconds - last update time
  IntColumn get updatedAt => integer()();

  /// Soft delete flag (0 = not deleted, 1 = deleted)
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();

  /// JSON for extensibility
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Custom converter for entry type enum
class EntryTypeConverter extends TypeConverter<String, String> {
  const EntryTypeConverter();

  @override
  String fromSql(String fromDb) {
    return fromDb;
  }

  @override
  String toSql(String value) {
    return value;
  }
}
