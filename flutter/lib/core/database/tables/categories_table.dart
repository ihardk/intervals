import 'package:drift/drift.dart';

/// Categories table - stores category definitions for auto-categorization
@DataClassName('CategoryData')
class Categories extends Table {
  /// Primary key - UUID v4
  TextColumn get id => text()();

  /// Category name (unique)
  TextColumn get name => text()();

  /// Hex color for UI (e.g., '#3B82F6')
  TextColumn get color => text().nullable()();

  /// JSON array of keywords for auto-categorization
  TextColumn get keywords => text()();

  /// Parent category for hierarchical categories
  TextColumn get parentCategory => text().nullable()();

  /// System vs user-created (0 = user-created, 1 = system)
  IntColumn get isSystem => integer().withDefault(const Constant(0))();

  /// Creation timestamp
  IntColumn get createdAt => integer()();

  /// Last update timestamp
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
