// Comprehensive tests for IntervalsDao, InsightsDao, StreaksDao, and ExportsDao
// This file contains all remaining DAO tests to complete the test suite

import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:interval/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUpAll(() async {
    if (Platform.isWindows || Platform.isLinux) {
      applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
  });

  setUp(() {
    database = AppDatabase.test(NativeDatabase.memory());
  });

  tearDown() async {
    await database.close();
  };

  // ==================== INTERVALS DAO TESTS ====================
  group('IntervalsDao Tests', () {
    test('Create and retrieve interval', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final dao = database.intervalsDao;

      await dao.insertInterval(IntervalsCompanion.insert(
        id: 'int_001',
        scheduledTime: now,
        intervalDuration: 900000, // 15 minutes
        responseType: const Value('text'),
        createdAt: now,
      ));

      final interval = await dao.getIntervalById('int_001');
      expect(interval, isNotNull);
      expect(interval!.responseType, 'text');
    });

    test('Get completion rate returns correct percentage', () async {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final dao = database.intervalsDao;

      // Create 10 intervals, 7 completed
      for (int i = 0; i < 10; i++) {
        await dao.insertInterval(IntervalsCompanion.insert(
          id: 'int_$i',
          scheduledTime: startOfDay + (i * 1000),
          intervalDuration: 900000, // 15 minutes
          isCompleted: Value(i < 7 ? 1 : 0),
          responseType: Value(i < 7 ? 'logged' : null),
          createdAt: startOfDay,
        ));
      }

      final rate = await dao.getCompletionRate(now);
      expect(rate, 0.7); // 7/10 = 0.7 (70%)
    });

    test('Complete interval updates status', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final dao = database.intervalsDao;

      await dao.insertInterval(IntervalsCompanion.insert(
        id: 'int_complete',
        scheduledTime: now,
        intervalDuration: 900000, // 15 minutes
        isCompleted: const Value(0),
        createdAt: now,
      ));

      await dao.completeInterval(
        id: 'int_complete',
        responseType: 'logged',
        responseTime: now,
      );
      final completed = await dao.getIntervalById('int_complete');

      expect(completed!.isCompleted, 1);
      expect(completed.responseType, 'logged');
    });
  });

  // ==================== INSIGHTS DAO TESTS ====================
  group('InsightsDao Tests', () {
    test('Create and retrieve insight', () async {
      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dao = database.insightsDao;

      await dao.insertInsight(InsightsCompanion.insert(
        id: 'insight_001',
        insightType: 'daily',
        date: date,
        data: '{}',
        createdAt: now.millisecondsSinceEpoch,
      ));

      final insight = await dao.getInsightById('insight_001');
      expect(insight, isNotNull);
      expect(insight!.insightType, 'daily');
    });

    test('Upsert insight replaces existing', () async {
      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dao = database.insightsDao;

      await dao.upsertInsight(InsightsCompanion.insert(
        id: 'insight_upsert',
        insightType: 'daily',
        date: date,
        data: '{\"count\": 10}',
        createdAt: now.millisecondsSinceEpoch,
      ));

      await dao.upsertInsight(InsightsCompanion.insert(
        id: 'insight_upsert',
        insightType: 'daily',
        date: date,
        data: '{\"count\": 20}',
        createdAt: now.millisecondsSinceEpoch,
      ));

      final insight = await dao.getInsightById('insight_upsert');
      expect(insight!.data, '{\"count\": 20}');
    });

    test('Delete expired insights removes old data', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expired = now - 86400000; // 1 day ago
      final dao = database.insightsDao;

      await dao.insertInsight(InsightsCompanion.insert(
        id: 'expired_insight',
        insightType: 'daily',
        date: '2025-01-01',
        data: '{}',
        createdAt: now,
        expiresAt: Value(expired),
      ));

      await dao.insertInsight(InsightsCompanion.insert(
        id: 'valid_insight',
        insightType: 'daily',
        date: '2025-12-13',
        data: '{}',
        createdAt: now,
        expiresAt: Value(now + 86400000), // Expires tomorrow
      ));

      await dao.deleteExpiredInsights();

      final expiredCheck = await dao.getInsightById('expired_insight');
      final validCheck = await dao.getInsightById('valid_insight');

      expect(expiredCheck, isNull);
      expect(validCheck, isNotNull);
    });
  });

  // ==================== STREAKS DAO TESTS ====================
  group('StreaksDao Tests', () {
    test('Create and retrieve streak', () async {
      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dao = database.streaksDao;

      await dao.insertStreak(StreaksCompanion.insert(
        id: 'streak_001',
        streakType: 'daily_logging',
        startDate: date,
        currentCount: 5,
        bestCount: 10,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ));

      final streak = await dao.getStreakById('streak_001');
      expect(streak, isNotNull);
      expect(streak!.currentCount, 5);
      expect(streak.bestCount, 10);
    });

    test('Increment streak increases count and updates best', () async {
      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dao = database.streaksDao;

      await dao.insertStreak(StreaksCompanion.insert(
        id: 'streak_inc',
        streakType: 'daily_logging',
        startDate: date,
        currentCount: 9,
        bestCount: 9,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ));

      await dao.incrementStreak('streak_inc');
      final updated = await dao.getStreakById('streak_inc');

      expect(updated!.currentCount, 10);
      expect(updated.bestCount, 10); // Should update best too
    });

    test('Break streak sets active to false', () async {
      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dao = database.streaksDao;

      await dao.insertStreak(StreaksCompanion.insert(
        id: 'streak_break',
        streakType: 'daily_logging',
        startDate: date,
        currentCount: 5,
        bestCount: 5,
        isActive: const Value(1),
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ));

      await dao.breakStreak('streak_break');
      final broken = await dao.getStreakById('streak_break');

      expect(broken!.isActive, 0);
      expect(broken.endDate, isNotNull);
    });

    test('Get active streak returns only active streaks', () async {
      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dao = database.streaksDao;

      await dao.insertStreak(StreaksCompanion.insert(
        id: 'active',
        streakType: 'daily_logging',
        startDate: date,
        currentCount: 5,
        bestCount: 5,
        isActive: const Value(1),
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ));

      await dao.insertStreak(StreaksCompanion.insert(
        id: 'inactive',
        streakType: 'daily_logging',
        startDate: date,
        currentCount: 3,
        bestCount: 3,
        isActive: const Value(0),
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ));

      final active = await dao.getActiveStreak('daily_logging');
      expect(active, isNotNull);
      expect(active!.id, 'active');
    });
  });

  // ==================== EXPORTS DAO TESTS ====================
  group('ExportsDao Tests', () {
    test('Create and retrieve export', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final dao = database.exportsDao;

      await dao.insertExport(ExportsCompanion.insert(
        id: 'export_001',
        exportType: 'csv',
        filePath: '/path/to/file.csv',
        dateRangeStart: '2025-01-01',
        dateRangeEnd: '2025-01-31',
        recordCount: const Value(100),
        fileSize: const Value(5000),
        createdAt: now,
      ));

      final export = await dao.getExportById('export_001');
      expect(export, isNotNull);
      expect(export!.exportType, 'csv');
      expect(export.recordCount, 100);
    });

    test('Get exports by type filters correctly', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final dao = database.exportsDao;

      await dao.insertExport(ExportsCompanion.insert(
        id: 'csv_export',
        exportType: 'csv',
        filePath: '/path/to/file.csv',
        dateRangeStart: '2025-01-01',
        dateRangeEnd: '2025-01-31',
        createdAt: now,
      ));

      await dao.insertExport(ExportsCompanion.insert(
        id: 'json_export',
        exportType: 'json',
        filePath: '/path/to/file.json',
        dateRangeStart: '2025-01-01',
        dateRangeEnd: '2025-01-31',
        createdAt: now,
      ));

      final csvExports = await dao.getExportsByType('csv');
      expect(csvExports.length, 1);
      expect(csvExports.first.exportType, 'csv');
    });

    test('Delete old exports removes exports older than threshold', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final old = now - (31 * 86400000); // 31 days ago
      final dao = database.exportsDao;

      await dao.insertExport(ExportsCompanion.insert(
        id: 'old_export',
        exportType: 'csv',
        filePath: '/old.csv',
        dateRangeStart: '2024-01-01',
        dateRangeEnd: '2024-01-31',
        createdAt: old,
      ));

      await dao.insertExport(ExportsCompanion.insert(
        id: 'recent_export',
        exportType: 'csv',
        filePath: '/recent.csv',
        dateRangeStart: '2025-01-01',
        dateRangeEnd: '2025-01-31',
        createdAt: now,
      ));

      await dao.deleteOldExports(30); // Delete exports older than 30 days

      final oldCheck = await dao.getExportById('old_export');
      final recentCheck = await dao.getExportById('recent_export');

      expect(oldCheck, isNull);
      expect(recentCheck, isNotNull);
    });

    test('Get total export size sums all file sizes', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final dao = database.exportsDao;

      await dao.insertExport(ExportsCompanion.insert(
        id: 'export_1',
        exportType: 'csv',
        filePath: '/file1.csv',
        dateRangeStart: '2025-01-01',
        dateRangeEnd: '2025-01-31',
        fileSize: const Value(1000),
        createdAt: now,
      ));

      await dao.insertExport(ExportsCompanion.insert(
        id: 'export_2',
        exportType: 'json',
        filePath: '/file2.json',
        dateRangeStart: '2025-01-01',
        dateRangeEnd: '2025-01-31',
        fileSize: const Value(2000),
        createdAt: now,
      ));

      final totalSize = await dao.getTotalExportSize();
      expect(totalSize, 3000);
    });
  });
}
