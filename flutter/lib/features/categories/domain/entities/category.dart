import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Category entity - represents a log category for auto-categorization
@freezed
class Category with _$Category {
  const factory Category({
    required String id, // UUID v4
    required String name, // Category name (unique)
    String? color, // Hex color for UI (e.g., '#3B82F6')
    @Default([]) List<String> keywords, // Keywords for auto-categorization
    String? parentCategory, // Parent category for hierarchical structure
    @Default(false) bool isSystem, // System vs user-created
    required int createdAt, // Creation timestamp
    required int updatedAt, // Last update timestamp
  }) = _Category;

  const Category._();

  /// Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  /// Check if this is a user-created category
  bool get isUserCreated => !isSystem;

  /// Check if category matches content
  bool matchesContent(String content) {
    final lowerContent = content.toLowerCase();
    return keywords.any((keyword) => lowerContent.contains(keyword.toLowerCase()));
  }

  /// Get keyword count
  int get keywordCount => keywords.length;
}

/// Input for creating a new category
@freezed
class CreateCategoryInput with _$CreateCategoryInput {
  const factory CreateCategoryInput({
    required String name,
    required List<String> keywords,
    String? color,
    String? parentCategory,
  }) = _CreateCategoryInput;
}

/// Input for updating an existing category
@freezed
class UpdateCategoryInput with _$UpdateCategoryInput {
  const factory UpdateCategoryInput({
    required String id,
    String? name,
    List<String>? keywords,
    String? color,
    String? parentCategory,
  }) = _UpdateCategoryInput;
}

/// Default system categories
class DefaultCategories {
  static const work = 'Work';
  static const breakCategory = 'Break';
  static const learning = 'Learning';
  static const social = 'Social';
  static const distraction = 'Distraction';

  static const List<String> all = [
    work,
    breakCategory,
    learning,
    social,
    distraction,
  ];

  // Private constructor
  DefaultCategories._();
}
