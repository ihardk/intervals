import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/categories/domain/entities/category.dart';
import 'package:interval/features/categories/domain/repositories/category_repository.dart';
import 'package:interval/features/categories/domain/usecases/create_category.dart';

@GenerateMocks([CategoryRepository])
import 'create_category_test.mocks.dart';

void main() {
  late CreateCategory usecase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    usecase = CreateCategory(mockCategoryRepository);
  });

  const tName = 'New Category';
  const tKeywords = ['new', 'category'];
  final tCategory = Category(
    id: '1',
    name: tName,
    keywords: tKeywords,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    updatedAt: DateTime.now().millisecondsSinceEpoch,
  );

  test(
    'should create category via repository',
    () async {
      // Arrange
      when(mockCategoryRepository.createCategory(
        name: anyNamed('name'),
        keywords: anyNamed('keywords'),
        color: anyNamed('color'),
        icon: anyNamed('icon'),
      )).thenAnswer((_) async => Right(tCategory));

      // Act
      final result = await usecase(name: tName, keywords: tKeywords);

      // Assert
      expect(result, Right(tCategory));
      verify(mockCategoryRepository.createCategory(
        name: tName,
        keywords: tKeywords,
      ));
      verifyNoMoreInteractions(mockCategoryRepository);
    },
  );
}
