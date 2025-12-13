import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

/// Data Access Object for Categories table
/// Provides operations for category management and auto-categorization
@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  /// Get a category by ID
  Future<CategoryData?> getCategoryById(String id) {
    return (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Get a category by name
  Future<CategoryData?> getCategoryByName(String name) {
    return (select(categories)..where((c) => c.name.equals(name))).getSingleOrNull();
  }

  /// Get all categories
  Future<List<CategoryData>> getAllCategories() {
    return (select(categories)..orderBy([(c) => OrderingTerm.asc(c.name)])).get();
  }

  /// Get system categories
  Future<List<CategoryData>> getSystemCategories() {
    return (select(categories)
          ..where((c) => c.isSystem.equals(1))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Get user-created categories
  Future<List<CategoryData>> getUserCategories() {
    return (select(categories)
          ..where((c) => c.isSystem.equals(0))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Insert a new category
  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  /// Update a category
  Future<bool> updateCategory(CategoryData category) {
    return update(categories).replace(category);
  }

  /// Delete a category (only user-created categories)
  Future<int> deleteCategory(String id) {
    return (delete(categories)
          ..where((c) => c.id.equals(id))
          ..where((c) => c.isSystem.equals(0)))
        .go();
  }

  /// Watch all categories
  Stream<List<CategoryData>> watchAllCategories() {
    return (select(categories)..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();
  }

  /// Watch a specific category
  Stream<CategoryData?> watchCategory(String id) {
    return (select(categories)..where((c) => c.id.equals(id))).watchSingleOrNull();
  }

  /// Get category count
  Future<int> getCategoryCount() async {
    final countExp = categories.id.count();
    final query = selectOnly(categories)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }
}
