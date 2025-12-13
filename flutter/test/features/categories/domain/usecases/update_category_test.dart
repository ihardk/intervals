import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/categories/domain/entities/category.dart';
import 'package:interval/features/categories/domain/repositories/category_repository.dart';
import 'package:interval/features/categories/domain/usecases/update_category.dart';

@GenerateMocks([CategoryRepository])
import 'update_category_test.mocks.dart';

void main() {
  late UpdateCategory usecase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    usecase = UpdateCategory(mockCategoryRepository);
  });

  final tCategory = Category(
    id: '1',
    name: 'Updated',
    createdAt: DateTime.now().millisecondsSinceEpoch,
    updatedAt: DateTime.now().millisecondsSinceEpoch,
  );

  test(
    'should update category via repository',
    () async {
      // Arrange
      when(mockCategoryRepository.updateCategory(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(tCategory);

      // Assert
      expect(result, const Right(null));
      verify(mockCategoryRepository.updateCategory(tCategory));
      verifyNoMoreInteractions(mockCategoryRepository);
    },
  );
}
