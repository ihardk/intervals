import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/category.dart';

part 'categories_event.freezed.dart';

@freezed
class CategoriesEvent with _$CategoriesEvent {
  const factory CategoriesEvent.loadCategories() = LoadCategories;
  const factory CategoriesEvent.addCategory({
    required String name,
    required String color,
    @Default([]) List<String> keywords,
  }) = AddCategory;
  const factory CategoriesEvent.editCategory(Category category) = EditCategory;
  const factory CategoriesEvent.removeCategory(String id) = RemoveCategory;
}
