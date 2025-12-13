import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/streaks/domain/repositories/streak_repository.dart';
import 'package:interval/features/streaks/domain/usecases/get_current_streak.dart';

@GenerateMocks([StreakRepository])
import 'get_current_streak_test.mocks.dart';

void main() {
  late GetCurrentStreak usecase;
  late MockStreakRepository mockStreakRepository;

  setUp(() {
    mockStreakRepository = MockStreakRepository();
    usecase = GetCurrentStreak(mockStreakRepository);
  });

  const tStreakType = 'daily_logs';
  const tCount = 5;

  test(
    'should get current streak count from repository',
    () async {
      // Arrange
      when(mockStreakRepository.getCurrentStreakCount(any))
          .thenAnswer((_) async => const Right(tCount));

      // Act
      final result = await usecase(tStreakType);

      // Assert
      expect(result, const Right(tCount));
      verify(mockStreakRepository.getCurrentStreakCount(tStreakType));
      verifyNoMoreInteractions(mockStreakRepository);
    },
  );
}
