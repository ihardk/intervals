import 'package:drift/drift.dart';

/// Exports table - tracks data export history
@DataClassName('ExportData')
class Exports extends Table {
  /// Primary key - UUID v4
  TextColumn get id => text()();

  /// Export type: 'csv' or 'json'
  TextColumn get exportType => text()();

  /// Date range start (ISO date YYYY-MM-DD)
  TextColumn get dateRangeStart => text()();

  /// Date range end (ISO date YYYY-MM-DD)
  TextColumn get dateRangeEnd => text()();

  /// File path where export was saved
  TextColumn get filePath => text()();

  /// File size in bytes
  IntColumn get fileSize => integer().nullable()();

  /// Number of records exported
  IntColumn get recordCount => integer().nullable()();

  /// Creation timestamp
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
