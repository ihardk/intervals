import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/categories/domain/entities/category.dart';
import 'package:interval/features/categories/domain/repositories/category_repository.dart';
import 'package:interval/features/categories/domain/usecases/get_all_categories.dart';

@GenerateMocks([CategoryRepository])
import 'get_all_categories_test.mocks.dart';

void main() {
  late GetAllCategories usecase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    usecase = GetAllCategories(mockCategoryRepository);
  });

  final tCategories = [
    Category(
      id: '1',
      name: 'Work',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ),
    Category(
      id: '2',
      name: 'Personal',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ),
  ];

  test(
    'should get all categories from the repository',
    () async {
      // Arrange
      when(mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => Right(tCategories));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tCategories));
      verify(mockCategoryRepository.getAllCategories());
      verifyNoMoreInteractions(mockCategoryRepository);
    },
  );
}
