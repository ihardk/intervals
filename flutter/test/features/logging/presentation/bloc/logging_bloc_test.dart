import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/logging/domain/entities/log.dart';
import 'package:interval/features/logging/domain/usecases/create_log.dart';
import 'package:interval/features/logging/domain/usecases/delete_log.dart';
import 'package:interval/features/logging/domain/usecases/get_today_logs.dart';
import 'package:interval/features/logging/domain/usecases/search_logs.dart';
import 'package:interval/features/logging/domain/usecases/update_log.dart';
import 'package:interval/features/logging/presentation/bloc/logging_bloc.dart';
import 'package:interval/features/logging/presentation/bloc/logging_event.dart';
import 'package:interval/features/logging/presentation/bloc/logging_state.dart';

@GenerateMocks([
  CreateLog,
  GetTodayLogs,
  UpdateLog,
  DeleteLog,
  SearchLogs,
])
import 'logging_bloc_test.mocks.dart';

void main() {
  late LoggingBloc bloc;
  late MockCreateLog mockCreateLog;
  late MockGetTodayLogs mockGetTodayLogs;
  late MockUpdateLog mockUpdateLog;
  late MockDeleteLog mockDeleteLog;
  late MockSearchLogs mockSearchLogs;

  setUp(() {
    mockCreateLog = MockCreateLog();
    mockGetTodayLogs = MockGetTodayLogs();
    mockUpdateLog = MockUpdateLog();
    mockDeleteLog = MockDeleteLog();
    mockSearchLogs = MockSearchLogs();

    bloc = LoggingBloc(
      createLog: mockCreateLog,
      getTodayLogs: mockGetTodayLogs,
      updateLog: mockUpdateLog,
      deleteLog: mockDeleteLog,
      searchLogs: mockSearchLogs,
    );
  });

  const tLog = Log(
    id: '1',
    content: 'Test Log',
    entryType: EntryType.text,
    timestamp: 1234567890,
    createdAt: 1234567890,
    updatedAt: 1234567890,
  );

  final tLogs = [tLog];

  test('initial state is LoggingInitial', () {
    expect(bloc.state, const LoggingState.initial());
  });

  group('LoadTodayLogs', () {
    blocTest<LoggingBloc, LoggingState>(
      'emits [LoggingLoading, LoggingLoaded] when successful',
      build: () {
        when(mockGetTodayLogs()).thenAnswer((_) async => Right(tLogs));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoggingEvent.loadTodayLogs()),
      expect: () => [
        const LoggingState.loading(),
        LoggingState.loaded(logs: tLogs),
      ],
      verify: (_) => verify(mockGetTodayLogs()),
    );

    blocTest<LoggingBloc, LoggingState>(
      'emits [LoggingLoading, LoggingError] when failure',
      build: () {
        when(mockGetTodayLogs())
            .thenAnswer((_) async => const Left(CacheFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoggingEvent.loadTodayLogs()),
      expect: () => [
        const LoggingState.loading(),
        const LoggingState.error(message: 'Error'),
      ],
    );
  });

  group('CreateLog', () {
    const tContent = 'Test Log';
    const tEntryType =
        'text'; // This might need to be enum or string depending on use case

    blocTest<LoggingBloc, LoggingState>(
      'emits [LoggingLoading, LoggingSuccess] when successful',
      build: () {
        // Mock createLog to return success
        when(mockCreateLog(
          content: anyNamed('content'),
          entryType: anyNamed('entryType'),
          audioPath: anyNamed('audioPath'),
          category: anyNamed('category'),
          tags: anyNamed('tags'),
          mood: anyNamed('mood'),
        )).thenAnswer((_) async => const Right(tLog));

        // Mock getTodayLogs for automatic reload
        when(mockGetTodayLogs()).thenAnswer((_) async => Right(tLogs));

        return bloc;
      },
      act: (bloc) => bloc.add(const LoggingEvent.createLog(
        content: tContent,
        entryType: tEntryType,
      )),
      expect: () => [
        const LoggingState.loading(),
        LoggingState.success(message: 'Log created successfully', logs: tLogs),
      ],
      verify: (_) {
        verify(mockCreateLog(content: tContent, entryType: tEntryType));
        verify(mockGetTodayLogs());
      },
    );
  });

  group('UpdateLog', () {
    blocTest<LoggingBloc, LoggingState>(
      'emits [LoggingLoading, LoggingSuccess] when successful',
      build: () {
        when(mockUpdateLog(any)).thenAnswer((_) async => const Right(null));
        when(mockGetTodayLogs()).thenAnswer((_) async => Right(tLogs));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoggingEvent.updateLog(log: tLog)),
      expect: () => [
        const LoggingState.loading(),
        LoggingState.success(message: 'Log updated successfully', logs: tLogs),
      ],
      verify: (_) {
        verify(mockUpdateLog(tLog));
        verify(mockGetTodayLogs());
      },
    );
  });

  group('DeleteLog', () {
    const tLogId = '1';

    blocTest<LoggingBloc, LoggingState>(
      'emits [LoggingLoading, LoggingSuccess] when successful',
      build: () {
        when(mockDeleteLog(any)).thenAnswer((_) async => const Right(null));
        when(mockGetTodayLogs()).thenAnswer((_) async => Right(tLogs));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoggingEvent.deleteLog(id: tLogId)),
      expect: () => [
        const LoggingState.loading(),
        LoggingState.success(message: 'Log deleted successfully', logs: tLogs),
      ],
      verify: (_) {
        verify(mockDeleteLog(tLogId));
        verify(mockGetTodayLogs());
      },
    );
  });

  group('SearchLogs', () {
    const tQuery = 'test';

    blocTest<LoggingBloc, LoggingState>(
      'emits [LoggingLoading, LoggingLoaded(isSearching: true)] when successful',
      build: () {
        when(mockSearchLogs(any)).thenAnswer((_) async => Right(tLogs));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoggingEvent.searchLogs(query: tQuery)),
      expect: () => [
        const LoggingState.loading(),
        LoggingState.loaded(
            logs: tLogs, isSearching: true, searchQuery: tQuery),
      ],
      verify: (_) => verify(mockSearchLogs(tQuery)),
    );
  });
}
