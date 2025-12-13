import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:interval/core/database/app_database.dart';
import 'package:interval/core/database/daos/logs_dao.dart';
import 'package:interval/core/database/tables/logs_table.dart';

void main() {
  late AppDatabase database;
  late LogsDao logsDao;

  setUpAll(() async {
    // Initialize sqlite3 for tests on desktop platforms
    if (Platform.isWindows || Platform.isLinux) {
      // Load sqlite3 library for tests
      applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
  });

  setUp(() {
    // Create in-memory database for testing
    database = AppDatabase.test(NativeDatabase.memory());
    logsDao = database.logsDao;
  });

  tearDown() async {
    await database.close();
  }

  /// Helper function to create log companion with required timestamps
  LogsCompanion createLogCompanion({
    required String id,
    required int timestamp,
    required String content,
    required String entryType,
    Value<String?> audioPath = const Value.absent(),
    Value<String> transcriptionStatus = const Value.absent(),
    Value<String?> category = const Value.absent(),
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return LogsCompanion.insert(
      id: id,
      timestamp: timestamp,
      content: content,
      entryType: entryType,
      audioPath: audioPath,
      transcriptionStatus: transcriptionStatus,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('LogsDao - CRUD Operations', () {
    test('Given a new log, When inserted, Then it should be retrievable by ID', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      final log = createLogCompanion(
        id: 'log_001',
        timestamp: now,
        content: 'Working on Flutter migration',
        entryType: 'text',
      );

      // When
      await logsDao.insertLog(log);
      final retrieved = await logsDao.getLogById('log_001');

      // Then
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'log_001');
      expect(retrieved.content, 'Working on Flutter migration');
      expect(retrieved.entryType, 'text');
      expect(retrieved.timestamp, now);
    });

    test('Given a non-existent ID, When querying, Then should return null', () async {
      // When
      final result = await logsDao.getLogById('non_existent');

      // Then
      expect(result, isNull);
    });

    test('Given an existing log, When updated, Then changes should persist', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await logsDao.insertLog(createLogCompanion(
        id: 'log_002',
        timestamp: now,
        content: 'Original content',
        entryType: 'text',
      ));

      // When
      final original = await logsDao.getLogById('log_002');
      final updated = original!.copyWith(content: 'Updated content');
      await logsDao.updateLog(updated);
      final retrieved = await logsDao.getLogById('log_002');

      // Then
      expect(retrieved!.content, 'Updated content');
      expect(retrieved.timestamp, now);
    });

    test('Given an existing log, When soft deleted, Then isDeleted should be true', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await logsDao.insertLog(createLogCompanion(
        id: 'log_003',
        timestamp: now,
        content: 'To be deleted',
        entryType: 'text',
      ));

      // When
      await logsDao.softDeleteLog('log_003');
      final retrieved = await logsDao.getLogById('log_003');

      // Then
      expect(retrieved!.isDeleted, 1);
    });

    test('Given a deleted log ID, When hard deleted, Then should not be retrievable', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await logsDao.insertLog(createLogCompanion(
        id: 'log_004',
        timestamp: now,
        content: 'To be hard deleted',
        entryType: 'text',
      ));

      // When
      await logsDao.deleteLog('log_004');
      final retrieved = await logsDao.getLogById('log_004');

      // Then
      expect(retrieved, isNull);
    });
  });

  group('LogsDao - Today Logs', () {
    test('Given logs from today, When querying today logs, Then should return only today logs', () async {
      // Given
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final yesterdayTime = todayStart - 86400000;

      await logsDao.insertLog(createLogCompanion(
        id: 'log_today_1',
        timestamp: todayStart + 3600000,
        content: 'Today log 1',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_today_2',
        timestamp: todayStart + 7200000,
        content: 'Today log 2',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_yesterday',
        timestamp: yesterdayTime,
        content: 'Yesterday log',
        entryType: 'text',
      ));

      // When
      final todayLogs = await logsDao.getTodayLogs();

      // Then
      expect(todayLogs.length, 2);
      expect(todayLogs.any((log) => log.id == 'log_today_1'), true);
      expect(todayLogs.any((log) => log.id == 'log_today_2'), true);
      expect(todayLogs.any((log) => log.id == 'log_yesterday'), false);
    });

    test('Given today logs, When querying, Then should be ordered by timestamp DESC', () async {
      // Given
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      await logsDao.insertLog(createLogCompanion(
        id: 'log_first',
        timestamp: todayStart + 3600000,
        content: 'First log',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_second',
        timestamp: todayStart + 7200000,
        content: 'Second log',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_third',
        timestamp: todayStart + 10800000,
        content: 'Third log',
        entryType: 'text',
      ));

      // When
      final todayLogs = await logsDao.getTodayLogs();

      // Then
      expect(todayLogs[0].id, 'log_third'); // Most recent first
      expect(todayLogs[1].id, 'log_second');
      expect(todayLogs[2].id, 'log_first');
    });

    test('Given no logs today, When querying today logs, Then should return empty list', () async {
      // Given
      final now = DateTime.now();
      final yesterdayTime = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch - 86400000;

      await logsDao.insertLog(createLogCompanion(
        id: 'log_yesterday',
        timestamp: yesterdayTime,
        content: 'Yesterday log',
        entryType: 'text',
      ));

      // When
      final todayLogs = await logsDao.getTodayLogs();

      // Then
      expect(todayLogs, isEmpty);
    });
  });

  group('LogsDao - Date Range Queries', () {
    test('Given logs in date range, When querying, Then should return logs within range', () async {
      // Given
      final date1 = DateTime(2025, 12, 10).millisecondsSinceEpoch;
      final date2 = DateTime(2025, 12, 11).millisecondsSinceEpoch;
      final date3 = DateTime(2025, 12, 12).millisecondsSinceEpoch;
      final date4 = DateTime(2025, 12, 13).millisecondsSinceEpoch;

      await logsDao.insertLog(createLogCompanion(
        id: 'log_dec10',
        timestamp: date1,
        content: 'Dec 10',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_dec11',
        timestamp: date2,
        content: 'Dec 11',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_dec12',
        timestamp: date3,
        content: 'Dec 12',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_dec13',
        timestamp: date4,
        content: 'Dec 13',
        entryType: 'text',
      ));

      // When
      final rangeLogs = await logsDao.getLogsByDateRange(date2, date3);

      // Then
      expect(rangeLogs.length, 2);
      expect(rangeLogs.any((log) => log.id == 'log_dec11'), true);
      expect(rangeLogs.any((log) => log.id == 'log_dec12'), true);
    });
  });

  group('LogsDao - Category Filtering', () {
    test('Given logs with categories, When filtering by category, Then should return matching logs', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;

      await logsDao.insertLog(createLogCompanion(
        id: 'log_work_1',
        timestamp: now,
        content: 'Working on code',
        entryType: 'text',
        category: const Value('cat_work'),
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_work_2',
        timestamp: now + 1000,
        content: 'In meeting',
        entryType: 'text',
        category: const Value('cat_work'),
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_break',
        timestamp: now + 2000,
        content: 'Coffee break',
        entryType: 'text',
        category: const Value('cat_break'),
      ));

      // When
      final workLogs = await logsDao.getLogsByCategory('cat_work');

      // Then
      expect(workLogs.length, 2);
      expect(workLogs.every((log) => log.category == 'cat_work'), true);
    });

    test('Given category with no logs, When filtering, Then should return empty list', () async {
      // When
      final logs = await logsDao.getLogsByCategory('cat_learning');

      // Then
      expect(logs, isEmpty);
    });
  });

  group('LogsDao - Search Functionality', () {
    test('Given logs with searchable content, When searching, Then should return matching logs', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;

      await logsDao.insertLog(createLogCompanion(
        id: 'log_flutter_1',
        timestamp: now,
        content: 'Working on Flutter migration',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_flutter_2',
        timestamp: now + 1000,
        content: 'Learning Flutter widgets',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_react',
        timestamp: now + 2000,
        content: 'Working on React Native',
        entryType: 'text',
      ));

      // When
      final results = await logsDao.searchLogs('Flutter');

      // Then
      expect(results.length, 2);
      expect(results.any((log) => log.id == 'log_flutter_1'), true);
      expect(results.any((log) => log.id == 'log_flutter_2'), true);
      expect(results.any((log) => log.id == 'log_react'), false);
    });

    test('Given search with no matches, When searching, Then should return empty list', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      await logsDao.insertLog(createLogCompanion(
        id: 'log_work',
        timestamp: now,
        content: 'Working on code',
        entryType: 'text',
      ));

      // When
      final results = await logsDao.searchLogs('NonExistentTerm');

      // Then
      expect(results, isEmpty);
    });
  });

  group('LogsDao - Statistics', () {
    test('Given multiple logs, When counting, Then should return correct count', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < 5; i++) {
        await logsDao.insertLog(createLogCompanion(
          id: 'log_$i',
          timestamp: now + (i * 1000),
          content: 'Log $i',
          entryType: 'text',
        ));
      }

      // When
      final count = await logsDao.getLogsCount();

      // Then
      expect(count, 5);
    });

    test('Given logs with different entry types, When counting by type, Then should return correct count', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;

      await logsDao.insertLog(createLogCompanion(
        id: 'log_text_1',
        timestamp: now,
        content: 'Text 1',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_text_2',
        timestamp: now + 1000,
        content: 'Text 2',
        entryType: 'text',
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_voice',
        timestamp: now + 2000,
        content: 'Voice',
        entryType: 'voice',
      ));

      // When
      final textCount = await logsDao.getLogsCountByType('text');
      final voiceCount = await logsDao.getLogsCountByType('voice');

      // Then
      expect(textCount, 2);
      expect(voiceCount, 1);
    });
  });

  group('LogsDao - Stream Watchers', () {
    test('Given today logs stream, When new log inserted, Then stream should emit update', () async {
      // Given
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      // When
      final stream = logsDao.watchTodayLogs();

      // Then
      expectLater(
        stream,
        emitsInOrder([
          [], // Initial empty state
          hasLength(1), // After first insert
          hasLength(2), // After second insert
        ]),
      );

      // Trigger emissions
      await Future.delayed(const Duration(milliseconds: 10));
      await logsDao.insertLog(createLogCompanion(
        id: 'log_stream_1',
        timestamp: todayStart + 1000,
        content: 'Stream log 1',
        entryType: 'text',
      ));

      await Future.delayed(const Duration(milliseconds: 10));
      await logsDao.insertLog(createLogCompanion(
        id: 'log_stream_2',
        timestamp: todayStart + 2000,
        content: 'Stream log 2',
        entryType: 'text',
      ));
    });

    test('Given logs by category stream, When new matching log inserted, Then stream should emit', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      final stream = logsDao.watchLogsByCategory('cat_work');

      // Then
      expectLater(
        stream,
        emitsInOrder([
          [], // Initial empty
          hasLength(1), // After insert
        ]),
      );

      // When
      await Future.delayed(const Duration(milliseconds: 10));
      await logsDao.insertLog(createLogCompanion(
        id: 'log_work_stream',
        timestamp: now,
        content: 'Work log',
        entryType: 'text',
        category: const Value('cat_work'),
      ));
    });
  });

  group('LogsDao - Bulk Operations', () {
    test('Given multiple logs to delete, When bulk deleting, Then all should be removed', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      final ids = ['bulk_1', 'bulk_2', 'bulk_3'];

      for (final id in ids) {
        await logsDao.insertLog(createLogCompanion(
          id: id,
          timestamp: now,
          content: 'Bulk log $id',
          entryType: 'text',
        ));
      }

      // When
      await logsDao.deleteLogsByIds(ids);

      // Then
      for (final id in ids) {
        final log = await logsDao.getLogById(id);
        expect(log, isNull);
      }
    });

    test('Given all logs, When deleting all, Then database should be empty', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < 3; i++) {
        await logsDao.insertLog(createLogCompanion(
          id: 'log_$i',
          timestamp: now + (i * 1000),
          content: 'Log $i',
          entryType: 'text',
        ));
      }

      // When
      await logsDao.deleteAllLogs();
      final count = await logsDao.getLogsCount();

      // Then
      expect(count, 0);
    });
  });

  group('LogsDao - Audio and Transcription', () {
    test('Given voice log with audio path, When inserted, Then should store audio path', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;
      final log = createLogCompanion(
        id: 'log_voice',
        timestamp: now,
        content: 'Transcribed text',
        entryType: 'voice',
        audioPath: const Value('/path/to/audio.m4a'),
        transcriptionStatus: const Value('complete'),
      );

      // When
      await logsDao.insertLog(log);
      final retrieved = await logsDao.getLogById('log_voice');

      // Then
      expect(retrieved!.audioPath, '/path/to/audio.m4a');
      expect(retrieved.entryType, 'voice');
      expect(retrieved.transcriptionStatus, 'complete');
    });

    test('Given logs with pending transcription, When querying, Then should return only pending', () async {
      // Given
      final now = DateTime.now().millisecondsSinceEpoch;

      await logsDao.insertLog(createLogCompanion(
        id: 'log_pending',
        timestamp: now,
        content: '',
        entryType: 'voice',
        transcriptionStatus: const Value('pending'),
      ));

      await logsDao.insertLog(createLogCompanion(
        id: 'log_complete',
        timestamp: now + 1000,
        content: 'Transcribed',
        entryType: 'voice',
        transcriptionStatus: const Value('complete'),
      ));

      // When
      final pendingLogs = await logsDao.getLogsByTranscriptionStatus('pending');

      // Then
      expect(pendingLogs.length, 1);
      expect(pendingLogs.first.id, 'log_pending');
    });
  });
}
