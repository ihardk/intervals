import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

/// Repository interface for Category operations
/// Manages categories and auto-categorization logic
abstract class CategoryRepository {
  /// Get a category by ID
  Future<Either<Failure, Category>> getCategoryById(String id);

  /// Get all categories (system + user)
  Future<Either<Failure, List<Category>>> getAllCategories();

  /// Get system categories only
  Future<Either<Failure, List<Category>>> getSystemCategories();

  /// Get user-created categories only
  Future<Either<Failure, List<Category>>> getUserCategories();

  /// Create a new user category
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required List<String> keywords,
    String? color,
    String? icon,
  });

  /// Update an existing category
  Future<Either<Failure, void>> updateCategory(Category category);

  /// Delete a user category
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Auto-categorize content based on keywords
  /// Returns the best matching category ID or null if no match
  Future<Either<Failure, String?>> categorizeContent(String content);

  /// Get categories count
  Future<Either<Failure, int>> getCategoriesCount();

  /// Watch all categories (reactive stream)
  Stream<Either<Failure, List<Category>>> watchCategories();
}
