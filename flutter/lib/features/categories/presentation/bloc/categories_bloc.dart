import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_categories.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';

import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetAllCategories getAllCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  CategoriesBloc({
    required this.getAllCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(const CategoriesState.initial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<EditCategory>(_onEditCategory);
    on<RemoveCategory>(_onRemoveCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesState.loading());
    final result = await getAllCategories();
    emit(result.fold(
      (failure) => CategoriesState.error(failure.message),
      (categories) => CategoriesState.loaded(categories),
    ));
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesState.loading());
    final result = await createCategory(
      name: event.name,
      keywords: event.keywords,
      color: event.color,
    );
    await result.fold(
      (failure) async => emit(CategoriesState.error(failure.message)),
      (_) async => add(const LoadCategories()),
    );
  }

  Future<void> _onEditCategory(
    EditCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesState.loading());
    final result = await updateCategory(event.category);
    await result.fold(
      (failure) async => emit(CategoriesState.error(failure.message)),
      (_) async => add(const LoadCategories()),
    );
  }

  Future<void> _onRemoveCategory(
    RemoveCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesState.loading());
    final result = await deleteCategory(event.id);
    await result.fold(
      (failure) async => emit(CategoriesState.error(failure.message)),
      (_) async => add(const LoadCategories()),
    );
  }
}
