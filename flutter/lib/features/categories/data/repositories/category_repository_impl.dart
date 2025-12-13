import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';

/// Implementation of CategoryRepository
/// Handles category management and auto-categorization logic
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoriesDao categoriesDao;

  CategoryRepositoryImpl({required this.categoriesDao});

  @override
  Future<Either<Failure, domain.Category>> getCategoryById(String id) async {
    try {
      final categoryData = await categoriesDao.getCategoryById(id);

      if (categoryData == null) {
        return Left(NotFoundFailure('Category not found with id: $id'));
      }

      return Right(_mapToDomain(categoryData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Category>>> getAllCategories() async {
    try {
      final categoriesData = await categoriesDao.getAllCategories();
      final categories = categoriesData.map(_mapToDomain).toList();
      return Right(categories);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to get all categories: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Category>>> getSystemCategories() async {
    try {
      final categoriesData = await categoriesDao.getSystemCategories();
      final categories = categoriesData.map(_mapToDomain).toList();
      return Right(categories);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to get system categories: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Category>>> getUserCategories() async {
    try {
      final categoriesData = await categoriesDao.getUserCategories();
      final categories = categoriesData.map(_mapToDomain).toList();
      return Right(categories);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to get user categories: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Category>> createCategory({
    required String name,
    required List<String> keywords,
    String? color,
    String? icon,
  }) async {
    try {
      final categoryId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      final categoryCompanion = CategoriesCompanion.insert(
        id: categoryId,
        name: name,
        keywords: jsonEncode(keywords),
        color: Value(color),
        createdAt: now,
        updatedAt: now,
      );

      await categoriesDao.insertCategory(categoryCompanion);
      final categoryData = await categoriesDao.getCategoryById(categoryId);

      if (categoryData == null) {
        return const Left(
            DatabaseFailure('Failed to retrieve created category'));
      }

      return Right(_mapToDomain(categoryData));
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to create category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(domain.Category category) async {
    try {
      final categoryData = _mapToData(category);
      await categoriesDao.updateCategory(categoryData);
      return const Right(null);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to update category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await categoriesDao.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to delete category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String?>> categorizeContent(String content) async {
    try {
      final categories = await categoriesDao.getAllCategories();
      final lowerContent = content.toLowerCase();

      for (final category in categories) {
        final keywords = jsonDecode(category.keywords) as List<dynamic>;

        for (final keyword in keywords) {
          if (lowerContent.contains(keyword.toString().toLowerCase())) {
            return Right(category.name); // Return name, not ID
          }
        }
      }

      return const Right(null); // No matching category
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to categorize content: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getCategoriesCount() async {
    try {
      final categories = await categoriesDao.getAllCategories();
      return Right(categories.length);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to get categories count: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<domain.Category>>> watchCategories() {
    try {
      return categoriesDao.watchAllCategories().map(
            (categoriesData) =>
                Right(categoriesData.map(_mapToDomain).toList()),
          );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch categories: ${e.toString()}')),
      );
    }
  }

  /// Map Drift CategoryData to domain Category entity
  domain.Category _mapToDomain(CategoryData data) {
    List<String> keywordsList = [];
    try {
      final decoded = jsonDecode(data.keywords) as List<dynamic>;
      keywordsList = decoded.map((e) => e.toString()).toList();
    } catch (e) {
      keywordsList = [];
    }

    return domain.Category(
      id: data.id,
      name: data.name,
      color: data.color,
      keywords: keywordsList,
      parentCategory: data.parentCategory,
      isSystem: data.isSystem == 1,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Map domain Category entity to Drift CategoryData
  CategoryData _mapToData(domain.Category category) {
    return CategoryData(
      id: category.id,
      name: category.name,
      color: category.color,
      keywords: jsonEncode(category.keywords),
      parentCategory: category.parentCategory,
      isSystem: category.isSystem ? 1 : 0,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}
