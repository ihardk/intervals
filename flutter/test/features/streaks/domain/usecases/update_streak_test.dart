import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/streaks/domain/entities/streak.dart';
import 'package:interval/features/streaks/domain/repositories/streak_repository.dart';
import 'package:interval/features/streaks/domain/usecases/update_streak.dart';

@GenerateMocks([StreakRepository])
import 'update_streak_test.mocks.dart';

void main() {
  late UpdateStreak usecase;
  late MockStreakRepository mockStreakRepository;

  setUp(() {
    mockStreakRepository = MockStreakRepository();
    usecase = UpdateStreak(mockStreakRepository);
  });

  const tStreak = Streak(
    id: '1',
    streakType: StreakType.dailyLogs,
    startDate: '2025-01-01',
    currentCount: 5,
    bestCount: 5,
    createdAt: 1234567890,
    updatedAt: 1234567890,
  );

  test(
    'should update streak via repository',
    () async {
      // Arrange
      when(mockStreakRepository.updateStreak(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(tStreak);

      // Assert
      expect(result, const Right(null));
      verify(mockStreakRepository.updateStreak(tStreak));
      verifyNoMoreInteractions(mockStreakRepository);
    },
  );
}
