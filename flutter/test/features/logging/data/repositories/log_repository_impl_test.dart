import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/database/daos/logs_dao.dart';
import 'package:interval/core/database/daos/categories_dao.dart';
import 'package:interval/core/database/app_database.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/logging/data/repositories/log_repository_impl.dart';
import 'package:interval/features/logging/domain/entities/log.dart' as domain;

@GenerateMocks([LogsDao, CategoriesDao])
import 'log_repository_impl_test.mocks.dart';

void main() {
  late LogRepositoryImpl repository;
  late MockLogsDao mockLogsDao;
  late MockCategoriesDao mockCategoriesDao;

  setUp(() {
    mockLogsDao = MockLogsDao();
    mockCategoriesDao = MockCategoriesDao();
    repository = LogRepositoryImpl(
      logsDao: mockLogsDao,
      categoriesDao: mockCategoriesDao,
    );
  });

  group('LogRepositoryImpl - Create Log', () {
    const tContent = 'Working on Flutter migration';
    const tEntryType = 'text';
    final tNow = DateTime.now().millisecondsSinceEpoch;

    test(
      'Given valid log data with auto-categorization disabled, '
      'When createLog is called, '
      'Then should insert log without category and return Right(Log)',
      () async {
        // Arrange
        final tLogData = LogData(
          id: 'log_001',
          timestamp: tNow,
          content: tContent,
          entryType: tEntryType,
          audioPath: null,
          transcriptionStatus: 'complete',
          category: null,
          tags: null,
          mood: null,
          createdAt: tNow,
          updatedAt: tNow,
          isDeleted: 0,
          metadata: null,
        );

        when(mockLogsDao.insertLog(any)).thenAnswer((_) async => 1);
        when(mockLogsDao.getLogById(any)).thenAnswer((_) async => tLogData);

        // Act
        final result = await repository.createLog(
          content: tContent,
          entryType: tEntryType,
        );

        // Assert
        expect(result, isA<Right<Failure, domain.Log>>());
        result.fold(
          (failure) => fail('Should return Right'),
          (log) {
            expect(log.content, tContent);
            expect(log.entryType, domain.EntryType.text);
            expect(log.category, isNull);
          },
        );
        verify(mockLogsDao.insertLog(any)).called(1);
        verify(mockLogsDao.getLogById(any)).called(1);
      },
    );

    test(
      'Given valid log data with auto-categorization enabled, '
      'When createLog is called with content matching a category, '
      'Then should insert log with auto-assigned category',
      () async {
        // Arrange - setup category matching
        final tCategoryData = CategoryData(
          id: 'cat_work',
          name: 'Work',
          keywords: '["flutter","coding","development"]',
          color: '#000000',
          parentCategory: null,
          isSystem: 1,
          createdAt: tNow,
          updatedAt: tNow,
        );

        final tLogDataWithCategory = LogData(
          id: 'log_002',
          timestamp: tNow,
          content: tContent,
          entryType: tEntryType,
          audioPath: null,
          transcriptionStatus: 'complete',
          category: 'cat_work',
          tags: null,
          mood: null,
          createdAt: tNow,
          updatedAt: tNow,
          isDeleted: 0,
          metadata: null,
        );

        when(mockCategoriesDao.getAllCategories())
            .thenAnswer((_) async => [tCategoryData]);
        when(mockLogsDao.insertLog(any)).thenAnswer((_) async => 1);
        when(mockLogsDao.getLogById(any))
            .thenAnswer((_) async => tLogDataWithCategory);

        // Act
        final result = await repository.createLog(
          content: tContent,
          entryType: tEntryType,
        );

        // Assert
        expect(result, isA<Right<Failure, domain.Log>>());
        result.fold(
          (failure) => fail('Should return Right'),
          (log) {
            expect(log.content, tContent);
            expect(log.category, 'cat_work');
          },
        );
      },
    );

    test(
      'Given database error, '
      'When createLog is called, '
      'Then should return Left(DatabaseFailure)',
      () async {
        // Arrange
        when(mockLogsDao.insertLog(any)).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.createLog(
          content: tContent,
          entryType: tEntryType,
        );

        // Assert
        expect(result, isA<Left<Failure, domain.Log>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (_) => fail('Should return Left'),
        );
      },
    );
  });

  group('LogRepositoryImpl - Get Today Logs', () {
    final tNow = DateTime.now();
    final tStartOfDay =
        DateTime(tNow.year, tNow.month, tNow.day).millisecondsSinceEpoch;

    test(
      'Given logs exist for today, '
      'When getTodayLogs is called, '
      'Then should return Right(List<Log>)',
      () async {
        // Arrange
        final tLogsList = [
          LogData(
            id: 'log_001',
            timestamp: tStartOfDay + 3600000,
            content: 'Morning log',
            entryType: 'text',
            audioPath: null,
            transcriptionStatus: 'complete',
            category: null,
            tags: null,
            mood: null,
            createdAt: tStartOfDay,
            updatedAt: tStartOfDay,
            isDeleted: 0,
            metadata: null,
          ),
          LogData(
            id: 'log_002',
            timestamp: tStartOfDay + 7200000,
            content: 'Afternoon log',
            entryType: 'text',
            audioPath: null,
            transcriptionStatus: 'complete',
            category: null,
            tags: null,
            mood: null,
            createdAt: tStartOfDay,
            updatedAt: tStartOfDay,
            isDeleted: 0,
            metadata: null,
          ),
        ];

        when(mockLogsDao.getTodayLogs()).thenAnswer((_) async => tLogsList);

        // Act
        final result = await repository.getTodayLogs();

        // Assert
        expect(result, isA<Right<Failure, List<domain.Log>>>());
        result.fold(
          (failure) => fail('Should return Right'),
          (logs) {
            expect(logs.length, 2);
            expect(logs[0].content, 'Morning log');
            expect(logs[1].content, 'Afternoon log');
          },
        );
        verify(mockLogsDao.getTodayLogs()).called(1);
      },
    );

    test(
      'Given no logs for today, '
      'When getTodayLogs is called, '
      'Then should return Right(empty list)',
      () async {
        // Arrange
        when(mockLogsDao.getTodayLogs()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getTodayLogs();

        // Assert
        expect(result, isA<Right<Failure, List<domain.Log>>>());
        result.fold(
          (failure) => fail('Should return Right'),
          (logs) => expect(logs, isEmpty),
        );
      },
    );

    test(
      'Given database error, '
      'When getTodayLogs is called, '
      'Then should return Left(DatabaseFailure)',
      () async {
        // Arrange
        when(mockLogsDao.getTodayLogs()).thenThrow(Exception('DB error'));

        // Act
        final result = await repository.getTodayLogs();

        // Assert
        expect(result, isA<Left<Failure, List<domain.Log>>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (_) => fail('Should return Left'),
        );
      },
    );
  });

  group('LogRepositoryImpl - Get Log By ID', () {
    const tLogId = 'log_123';
    final tNow = DateTime.now().millisecondsSinceEpoch;

    test(
      'Given a log exists with the ID, '
      'When getLogById is called, '
      'Then should return Right(Log)',
      () async {
        // Arrange
        final tLogData = LogData(
          id: tLogId,
          timestamp: tNow,
          content: 'Test log',
          entryType: 'text',
          audioPath: null,
          transcriptionStatus: 'complete',
          category: null,
          tags: null,
          mood: null,
          createdAt: tNow,
          updatedAt: tNow,
          isDeleted: 0,
          metadata: null,
        );

        when(mockLogsDao.getLogById(tLogId))
            .thenAnswer((_) async => tLogData);

        // Act
        final result = await repository.getLogById(tLogId);

        // Assert
        expect(result, isA<Right<Failure, domain.Log>>());
        result.fold(
          (failure) => fail('Should return Right'),
          (log) {
            expect(log.id, tLogId);
            expect(log.content, 'Test log');
          },
        );
        verify(mockLogsDao.getLogById(tLogId)).called(1);
      },
    );

    test(
      'Given no log exists with the ID, '
      'When getLogById is called, '
      'Then should return Left(NotFoundFailure)',
      () async {
        // Arrange
        when(mockLogsDao.getLogById(tLogId)).thenAnswer((_) async => null);

        // Act
        final result = await repository.getLogById(tLogId);

        // Assert
        expect(result, isA<Left<Failure, domain.Log>>());
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (_) => fail('Should return Left'),
        );
      },
    );
  });

  group('LogRepositoryImpl - Update Log', () {
    final tNow = DateTime.now().millisecondsSinceEpoch;
    final tLog = domain.Log(
      id: 'log_update',
      timestamp: tNow,
      content: 'Updated content',
      entryType: domain.EntryType.text,
      transcriptionStatus: domain.TranscriptionStatus.complete,
      isDeleted: false,
      createdAt: tNow,
      updatedAt: tNow,
    );

    test(
      'Given a valid log entity, '
      'When updateLog is called, '
      'Then should update the log and return Right(void)',
      () async {
        // Arrange
        when(mockLogsDao.updateLog(any)).thenAnswer((_) async => true);

        // Act
        final result = await repository.updateLog(tLog);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(mockLogsDao.updateLog(any)).called(1);
      },
    );

    test(
      'Given database error, '
      'When updateLog is called, '
      'Then should return Left(DatabaseFailure)',
      () async {
        // Arrange
        when(mockLogsDao.updateLog(any)).thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateLog(tLog);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (_) => fail('Should return Left'),
        );
      },
    );
  });

  group('LogRepositoryImpl - Delete Log', () {
    const tLogId = 'log_delete';

    test(
      'Given a log ID, '
      'When deleteLog is called, '
      'Then should soft delete the log and return Right(void)',
      () async {
        // Arrange
        when(mockLogsDao.softDeleteLog(tLogId)).thenAnswer((_) async => 1);

        // Act
        final result = await repository.deleteLog(tLogId);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(mockLogsDao.softDeleteLog(tLogId)).called(1);
      },
    );

    test(
      'Given database error, '
      'When deleteLog is called, '
      'Then should return Left(DatabaseFailure)',
      () async {
        // Arrange
        when(mockLogsDao.softDeleteLog(tLogId))
            .thenThrow(Exception('Delete failed'));

        // Act
        final result = await repository.deleteLog(tLogId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (_) => fail('Should return Left'),
        );
      },
    );
  });

  group('LogRepositoryImpl - Search Logs', () {
    const tQuery = 'flutter';
    final tNow = DateTime.now().millisecondsSinceEpoch;

    test(
      'Given a search query, '
      'When searchLogs is called, '
      'Then should return matching logs',
      () async {
        // Arrange
        final tMatchingLogs = [
          LogData(
            id: 'log_001',
            timestamp: tNow,
            content: 'Working on Flutter migration',
            entryType: 'text',
            audioPath: null,
            transcriptionStatus: 'complete',
            category: null,
            tags: null,
            mood: null,
            createdAt: tNow,
            updatedAt: tNow,
            isDeleted: 0,
            metadata: null,
          ),
        ];

        when(mockLogsDao.searchLogs(tQuery))
            .thenAnswer((_) async => tMatchingLogs);

        // Act
        final result = await repository.searchLogs(tQuery);

        // Assert
        expect(result, isA<Right<Failure, List<domain.Log>>>());
        result.fold(
          (failure) => fail('Should return Right'),
          (logs) {
            expect(logs.length, 1);
            expect(logs[0].content.toLowerCase(), contains('flutter'));
          },
        );
      },
    );
  });

  group('LogRepositoryImpl - Get Logs Count', () {
    test(
      'Given logs exist, '
      'When getLogsCount is called, '
      'Then should return total count',
      () async {
        // Arrange
        when(mockLogsDao.getLogsCount()).thenAnswer((_) async => 42);

        // Act
        final result = await repository.getLogsCount();

        // Assert
        expect(result, isA<Right<Failure, int>>());
        result.fold(
          (failure) => fail('Should return Right'),
          (count) => expect(count, 42),
        );
      },
    );
  });
}
