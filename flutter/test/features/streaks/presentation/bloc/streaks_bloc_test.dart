import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/streaks/domain/usecases/get_current_streak.dart';
import 'package:interval/features/streaks/presentation/bloc/streaks_bloc.dart';
import 'package:interval/features/streaks/presentation/bloc/streaks_event.dart';
import 'package:interval/features/streaks/presentation/bloc/streaks_state.dart';

@GenerateMocks([GetCurrentStreak])
import 'streaks_bloc_test.mocks.dart';

void main() {
  late StreaksBloc bloc;
  late MockGetCurrentStreak mockGetCurrentStreak;

  setUp(() {
    mockGetCurrentStreak = MockGetCurrentStreak();
    bloc = StreaksBloc(getCurrentStreak: mockGetCurrentStreak);
  });

  const tStreakCount = 5;
  const tType = 'daily';

  test('initial state is StreaksInitial', () {
    expect(bloc.state, const StreaksState.initial());
  });

  blocTest<StreaksBloc, StreaksState>(
    'emits [StreaksLoading, StreaksLoaded] when successful',
    build: () {
      when(mockGetCurrentStreak(any))
          .thenAnswer((_) async => const Right(tStreakCount));
      return bloc;
    },
    act: (bloc) => bloc.add(const StreaksEvent.loadStreak(tType)),
    expect: () => [
      const StreaksState.loading(),
      const StreaksState.loaded(tStreakCount),
    ],
    verify: (_) => verify(mockGetCurrentStreak(tType)),
  );

  blocTest<StreaksBloc, StreaksState>(
    'emits [StreaksLoading, StreaksError] when failure',
    build: () {
      when(mockGetCurrentStreak(any))
          .thenAnswer((_) async => const Left(CacheFailure('Error')));
      return bloc;
    },
    act: (bloc) => bloc.add(const StreaksEvent.loadStreak(tType)),
    expect: () => [
      const StreaksState.loading(),
      const StreaksState.error('Error'),
    ],
  );
}
