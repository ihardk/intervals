import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/features/history/presentation/bloc/history_bloc.dart';
import 'package:interval/features/history/presentation/bloc/history_event.dart';
import 'package:interval/features/history/presentation/bloc/history_state.dart';
import 'package:interval/features/logging/domain/entities/log.dart';
import 'package:interval/features/logging/domain/usecases/get_logs_by_date_range.dart';
import 'package:interval/core/errors/failures.dart';

@GenerateMocks([GetLogsByDateRange])
import 'history_bloc_test.mocks.dart';

void main() {
  late HistoryBloc bloc;
  late MockGetLogsByDateRange mockGetLogsByDateRange;

  setUp(() {
    mockGetLogsByDateRange = MockGetLogsByDateRange();
    bloc = HistoryBloc(getLogsByDateRange: mockGetLogsByDateRange);
  });

  final tStartDate = DateTime(2025, 1, 1);
  final tEndDate = DateTime(2025, 1, 31);
  final List<Log> tLogs = [
    const Log(
      id: '1',
      timestamp: 1234567890,
      content: 'Test Log',
      entryType: EntryType.text,
      createdAt: 1234567890,
      updatedAt: 1234567890,
    ),
  ];

  test('initial state is HistoryInitial', () {
    expect(bloc.state, const HistoryState.initial());
  });

  blocTest<HistoryBloc, HistoryState>(
    'emits [HistoryLoading, HistoryLoaded] when LoadHistory is added and usecase succeeds',
    build: () {
      when(mockGetLogsByDateRange(
        startTimestamp: anyNamed('startTimestamp'),
        endTimestamp: anyNamed('endTimestamp'),
      )).thenAnswer((_) async => Right(tLogs));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadHistory(
      startDate: tStartDate,
      endDate: tEndDate,
    )),
    expect: () => [
      const HistoryState.loading(),
      HistoryState.loaded(tLogs),
    ],
    verify: (_) {
      verify(mockGetLogsByDateRange(
        startTimestamp: tStartDate.millisecondsSinceEpoch,
        endTimestamp: tEndDate.millisecondsSinceEpoch,
      ));
    },
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits [HistoryLoading, HistoryError] when LoadHistory is added and usecase fails',
    build: () {
      when(mockGetLogsByDateRange(
        startTimestamp: anyNamed('startTimestamp'),
        endTimestamp: anyNamed('endTimestamp'),
      )).thenAnswer((_) async => const Left(CacheFailure('Cache Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadHistory(
      startDate: tStartDate,
      endDate: tEndDate,
    )),
    expect: () => [
      const HistoryState.loading(),
      const HistoryState.error('Cache Failure'),
    ],
  );
}
