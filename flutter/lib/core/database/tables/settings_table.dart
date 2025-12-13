import 'package:drift/drift.dart';

/// Settings table - stores user preferences and app configuration
@DataClassName('SettingData')
class Settings extends Table {
  /// Setting identifier (primary key)
  TextColumn get key => text()();

  /// Setting value (stored as JSON string)
  TextColumn get value => text()();

  /// Setting type: 'string', 'number', 'boolean', or 'json'
  TextColumn get type => text()();

  /// Last modification timestamp
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
