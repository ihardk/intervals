import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/categories/domain/entities/category.dart';
import 'package:interval/features/categories/domain/usecases/get_all_categories.dart';
import 'package:interval/features/categories/domain/usecases/create_category.dart';
import 'package:interval/features/categories/domain/usecases/update_category.dart';
import 'package:interval/features/categories/domain/usecases/delete_category.dart';
import 'package:interval/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:interval/features/categories/presentation/bloc/categories_event.dart';
import 'package:interval/features/categories/presentation/bloc/categories_state.dart';

@GenerateMocks([
  GetAllCategories,
  CreateCategory,
  UpdateCategory,
  DeleteCategory,
])
import 'categories_bloc_test.mocks.dart';

void main() {
  late CategoriesBloc bloc;
  late MockGetAllCategories mockGetAllCategories;
  late MockCreateCategory mockCreateCategory;
  late MockUpdateCategory mockUpdateCategory;
  late MockDeleteCategory mockDeleteCategory;

  setUp(() {
    mockGetAllCategories = MockGetAllCategories();
    mockCreateCategory = MockCreateCategory();
    mockUpdateCategory = MockUpdateCategory();
    mockDeleteCategory = MockDeleteCategory();

    bloc = CategoriesBloc(
      getAllCategories: mockGetAllCategories,
      createCategory: mockCreateCategory,
      updateCategory: mockUpdateCategory,
      deleteCategory: mockDeleteCategory,
    );
  });

  const tCategory = Category(
    id: '1',
    name: 'Work',
    color: '#FF0000',
    createdAt: 1234567890,
    updatedAt: 1234567890,
  );
  final tCategories = [tCategory];

  test('initial state is CategoriesInitial', () {
    expect(bloc.state, const CategoriesState.initial());
  });

  group('LoadCategories', () {
    blocTest<CategoriesBloc, CategoriesState>(
      'emits [CategoriesLoading, CategoriesLoaded] when successful',
      build: () {
        when(mockGetAllCategories())
            .thenAnswer((_) async => Right(tCategories));
        return bloc;
      },
      act: (bloc) => bloc.add(const CategoriesEvent.loadCategories()),
      expect: () => [
        const CategoriesState.loading(),
        CategoriesState.loaded(tCategories),
      ],
      verify: (_) => verify(mockGetAllCategories()),
    );
  });

  group('AddCategory', () {
    blocTest<CategoriesBloc, CategoriesState>(
      'emits [CategoriesLoading, CategoriesLoaded] when successful',
      build: () {
        when(mockCreateCategory(
          name: anyNamed('name'),
          keywords: anyNamed('keywords'),
          color: anyNamed('color'),
          icon: anyNamed('icon'),
        )).thenAnswer((_) async => const Right(tCategory));
        when(mockGetAllCategories.call())
            .thenAnswer((_) async => Right(tCategories));
        return bloc;
      },
      act: (bloc) => bloc.add(const CategoriesEvent.addCategory(
        name: 'Work',
        color: '#FF0000',
      )),
      expect: () => [
        const CategoriesState.loading(),
        CategoriesState.loaded(tCategories),
      ],
      verify: (_) {
        verify(mockCreateCategory(
            name: 'Work', keywords: [], color: '#FF0000', icon: null));
        verify(mockGetAllCategories.call());
      },
    );
  });
}
