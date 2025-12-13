import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/categories/domain/repositories/category_repository.dart';
import 'package:interval/features/categories/domain/usecases/delete_category.dart';

@GenerateMocks([CategoryRepository])
import 'delete_category_test.mocks.dart';

void main() {
  late DeleteCategory usecase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    usecase = DeleteCategory(mockCategoryRepository);
  });

  const tId = '123';

  test(
    'should delete category via repository',
    () async {
      // Arrange
      when(mockCategoryRepository.deleteCategory(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(tId);

      // Assert
      expect(result, const Right(null));
      verify(mockCategoryRepository.deleteCategory(tId));
      verifyNoMoreInteractions(mockCategoryRepository);
    },
  );
}
