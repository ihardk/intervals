import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/categories/domain/repositories/category_repository.dart';
import 'package:interval/features/categories/domain/usecases/categorize_log.dart';

@GenerateMocks([CategoryRepository])
import 'categorize_log_test.mocks.dart';

void main() {
  late CategorizeLog usecase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    usecase = CategorizeLog(mockCategoryRepository);
  });

  const tContent = 'Coding in Flutter';
  const tCategoryId = 'cat_1';

  test(
    'should return category id when content matches',
    () async {
      // Arrange
      when(mockCategoryRepository.categorizeContent(any))
          .thenAnswer((_) async => const Right(tCategoryId));

      // Act
      final result = await usecase(tContent);

      // Assert
      expect(result, const Right(tCategoryId));
      verify(mockCategoryRepository.categorizeContent(tContent));
      verifyNoMoreInteractions(mockCategoryRepository);
    },
  );
}
