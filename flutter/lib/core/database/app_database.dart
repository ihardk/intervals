import 'package:drift/drift.dart';
import '../constants/app_constants.dart';
import '../constants/intervals.dart';
import 'tables/logs_table.dart';
import 'tables/intervals_table.dart';
import 'tables/settings_table.dart';
import 'tables/insights_table.dart';
import 'tables/categories_table.dart';
import 'tables/streaks_table.dart';
import 'tables/exports_table.dart';
import 'daos/logs_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/intervals_dao.dart';
import 'daos/insights_dao.dart';
import 'daos/streaks_dao.dart';
import 'daos/exports_dao.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

/// Main application database
/// Uses Drift for type-safe SQL operations with SQLite
@DriftDatabase(
  tables: [
    Logs,
    Intervals,
    Settings,
    Insights,
    Categories,
    Streaks,
    Exports,
  ],
  daos: [
    LogsDao,
    SettingsDao,
    CategoriesDao,
    IntervalsDao,
    InsightsDao,
    StreaksDao,
    ExportsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  /// Test constructor for in-memory database
  AppDatabase.test(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _insertDefaultSettings();
          await _insertDefaultCategories();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations will be added here
          // Example:
          // if (from == 1 && to == 2) {
          //   await m.addColumn(logs, logs.newColumn);
          // }
        },
      );

  /// Insert default settings on database creation
  Future<void> _insertDefaultSettings() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await batch((batch) {
      batch.insertAll(settings, [
        SettingsCompanion.insert(
          key: AppConstants.keyIntervalDuration,
          value: IntervalConstants.defaultInterval.toString(),
          type: 'number',
          updatedAt: now,
        ),
        SettingsCompanion.insert(
          key: AppConstants.keyNotificationsEnabled,
          value: 'true',
          type: 'boolean',
          updatedAt: now,
        ),
        SettingsCompanion.insert(
          key: AppConstants.keyVoiceEnabled,
          value: 'true',
          type: 'boolean',
          updatedAt: now,
        ),
        SettingsCompanion.insert(
          key: AppConstants.keyTheme,
          value: 'dark',
          type: 'string',
          updatedAt: now,
        ),
        SettingsCompanion.insert(
          key: AppConstants.keyDailyReminderTime,
          value: '20:00',
          type: 'string',
          updatedAt: now,
        ),
        SettingsCompanion.insert(
          key: AppConstants.keyAutoCategorize,
          value: 'true',
          type: 'boolean',
          updatedAt: now,
        ),
        SettingsCompanion.insert(
          key: AppConstants.keyOnboardingCompleted,
          value: 'false',
          type: 'boolean',
          updatedAt: now,
        ),
      ]);
    });
  }

  /// Insert default categories on database creation
  Future<void> _insertDefaultCategories() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await batch((batch) {
      batch.insertAll(categories, [
        CategoriesCompanion.insert(
          id: 'cat_work',
          name: 'Work',
          color: const Value('#3B82F6'),
          keywords:
              '["coding", "meeting", "email", "project", "client", "work"]',
          isSystem: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: 'cat_break',
          name: 'Break',
          color: const Value('#10B981'),
          keywords: '["break", "coffee", "lunch", "rest", "walk", "snack"]',
          isSystem: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: 'cat_learning',
          name: 'Learning',
          color: const Value('#8B5CF6'),
          keywords:
              '["reading", "course", "tutorial", "studying", "research", "learning"]',
          isSystem: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: 'cat_social',
          name: 'Social',
          color: const Value('#F59E0B'),
          keywords:
              '["chat", "call", "social media", "messaging", "conversation"]',
          isSystem: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: 'cat_distraction',
          name: 'Distraction',
          color: const Value('#EF4444'),
          keywords:
              '["browsing", "youtube", "scrolling", "distracted", "procrastinating"]',
          isSystem: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
      ]);
    });
  }
}
