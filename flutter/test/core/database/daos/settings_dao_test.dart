import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:interval/core/database/app_database.dart';
import 'package:interval/core/database/daos/settings_dao.dart';

void main() {
  late AppDatabase database;
  late SettingsDao settingsDao;

  setUpAll(() async {
    // Initialize sqlite3 for tests on desktop platforms
    if (Platform.isWindows || Platform.isLinux) {
      applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
  });

  setUp(() {
    // Create in-memory database for testing
    database = AppDatabase.test(NativeDatabase.memory());
    settingsDao = database.settingsDao;
  });

  tearDown() async {
    await database.close();
  };

  group('SettingsDao - Basic Operations', () {
    test('Given a setting key-value, When set, Then it should be retrievable', () async {
      // Given
      const key = 'test_key';
      const value = 'test_value';
      const type = 'string';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved, isNotNull);
      expect(retrieved!.key, key);
      expect(retrieved.value, value);
      expect(retrieved.type, type);
    });

    test('Given a non-existent key, When querying, Then should return null', () async {
      // When
      final result = await settingsDao.getSetting('non_existent_key');

      // Then
      expect(result, isNull);
    });

    test('Given an existing setting, When updated, Then new value should be stored', () async {
      // Given
      const key = 'update_test';
      await settingsDao.setSetting(key, 'old_value', 'string');

      // When
      await settingsDao.setSetting(key, 'new_value', 'string');
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.value, 'new_value');
    });

    test('Given an existing setting, When deleted, Then should not be retrievable', () async {
      // Given
      const key = 'delete_test';
      await settingsDao.setSetting(key, 'value', 'string');

      // When
      await settingsDao.deleteSetting(key);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved, isNull);
    });
  });

  group('SettingsDao - Data Types', () {
    test('Given boolean setting, When stored, Then should preserve type', () async {
      // Given
      const key = 'bool_setting';
      const value = 'true';
      const type = 'boolean';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.type, 'boolean');
      expect(retrieved.value, 'true');
    });

    test('Given number setting, When stored, Then should preserve type', () async {
      // Given
      const key = 'number_setting';
      const value = '42';
      const type = 'number';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.type, 'number');
      expect(retrieved.value, '42');
    });

    test('Given string setting, When stored, Then should preserve type', () async {
      // Given
      const key = 'string_setting';
      const value = 'hello world';
      const type = 'string';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.type, 'string');
      expect(retrieved.value, 'hello world');
    });
  });

  group('SettingsDao - Batch Operations', () {
    test('Given multiple settings, When batch updated, Then all should be stored', () async {
      // Given
      final settingsMap = {
        'key1': (value: 'value1', type: 'string'),
        'key2': (value: 'true', type: 'boolean'),
        'key3': (value: '123', type: 'number'),
      };

      // When
      await settingsDao.updateSettings(settingsMap);

      // Then
      final key1 = await settingsDao.getSetting('key1');
      final key2 = await settingsDao.getSetting('key2');
      final key3 = await settingsDao.getSetting('key3');

      expect(key1!.value, 'value1');
      expect(key2!.value, 'true');
      expect(key3!.value, '123');
    });

    test('Given existing settings, When batch updated with new values, Then should replace', () async {
      // Given
      await settingsDao.setSetting('key1', 'old1', 'string');
      await settingsDao.setSetting('key2', 'old2', 'string');

      final newSettings = {
        'key1': (value: 'new1', type: 'string'),
        'key2': (value: 'new2', type: 'string'),
      };

      // When
      await settingsDao.updateSettings(newSettings);

      // Then
      final key1 = await settingsDao.getSetting('key1');
      final key2 = await settingsDao.getSetting('key2');

      expect(key1!.value, 'new1');
      expect(key2!.value, 'new2');
    });

    test('Given batch update with mixed new and existing, Then should handle correctly', () async {
      // Given
      await settingsDao.setSetting('existing', 'old', 'string');

      final settingsMap = {
        'existing': (value: 'updated', type: 'string'),
        'new': (value: 'fresh', type: 'string'),
      };

      // When
      await settingsDao.updateSettings(settingsMap);

      // Then
      final existing = await settingsDao.getSetting('existing');
      final newSetting = await settingsDao.getSetting('new');

      expect(existing!.value, 'updated');
      expect(newSetting!.value, 'fresh');
    });
  });

  group('SettingsDao - Get All Settings', () {
    test('Given no custom settings, When getting all, Then should return default settings', () async {
      // Note: Database initialization creates default settings
      // When
      final allSettings = await settingsDao.getAllSettings();

      // Then
      expect(allSettings.isNotEmpty, true); // Has default settings
    });

    test('Given multiple settings, When getting all, Then should return all', () async {
      // Given
      await settingsDao.setSetting('custom_key1', 'value1', 'string');
      await settingsDao.setSetting('custom_key2', 'value2', 'string');
      await settingsDao.setSetting('custom_key3', 'value3', 'string');

      // When
      final allSettings = await settingsDao.getAllSettings();

      // Then - should have defaults plus our custom ones
      expect(allSettings.any((s) => s.key == 'custom_key1'), true);
      expect(allSettings.any((s) => s.key == 'custom_key2'), true);
      expect(allSettings.any((s) => s.key == 'custom_key3'), true);
    });
  });

  group('SettingsDao - Reset Operations', () {
    test('Given settings exist, When reset all, Then all should be deleted', () async {
      // Given
      await settingsDao.setSetting('key1', 'value1', 'string');
      await settingsDao.setSetting('key2', 'value2', 'string');

      // When
      await settingsDao.resetAllSettings();
      final allSettings = await settingsDao.getAllSettings();

      // Then
      expect(allSettings, isEmpty);
    });
  });

  group('SettingsDao - Stream Watchers', () {
    test('Given setting stream, When value changes, Then stream should emit update', () async {
      // Given
      const key = 'unique_watch_test';
      final stream = settingsDao.watchSetting(key);

      // Then
      expectLater(
        stream,
        emitsInOrder([
          isNull, // Initial state - key doesn't exist in defaults
          isNotNull, // After first set
          predicate<SettingData>((s) => s.value == 'updated'), // After update
        ]),
      );

      // When
      await Future.delayed(const Duration(milliseconds: 10));
      await settingsDao.setSetting(key, 'initial', 'string');

      await Future.delayed(const Duration(milliseconds: 10));
      await settingsDao.setSetting(key, 'updated', 'string');
    });

    test('Given all settings stream, When settings change, Then stream should emit', () async {
      // Given - get initial count of default settings
      final initialSettings = await settingsDao.getAllSettings();
      final initialCount = initialSettings.length;

      final stream = settingsDao.watchAllSettings();

      // Then
      expectLater(
        stream,
        emitsInOrder([
          hasLength(initialCount), // Initial state with defaults
          hasLength(initialCount + 1), // After first insert
          hasLength(initialCount + 2), // After second insert
        ]),
      );

      // When
      await Future.delayed(const Duration(milliseconds: 10));
      await settingsDao.setSetting('unique_key1', 'value1', 'string');

      await Future.delayed(const Duration(milliseconds: 10));
      await settingsDao.setSetting('unique_key2', 'value2', 'string');
    });
  });

  group('SettingsDao - App Constants Integration', () {
    test('Given interval duration setting, When stored, Then should be retrievable', () async {
      // Given - using actual app constants
      const key = 'interval_duration';
      const value = '900000'; // 15 minutes
      const type = 'number';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.key, key);
      expect(retrieved.value, value);
      expect(retrieved.type, 'number');
    });

    test('Given notifications enabled setting, When stored, Then should be retrievable', () async {
      // Given
      const key = 'notifications_enabled';
      const value = 'true';
      const type = 'boolean';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.key, key);
      expect(retrieved.value, 'true');
      expect(retrieved.type, 'boolean');
    });

    test('Given theme setting, When stored, Then should be retrievable', () async {
      // Given
      const key = 'theme';
      const value = 'dark';
      const type = 'string';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.key, key);
      expect(retrieved.value, 'dark');
    });

    test('Given onboarding completed, When set to true, Then should persist', () async {
      // Given
      const key = 'onboarding_completed';

      // When
      await settingsDao.setSetting(key, 'false', 'boolean');
      final before = await settingsDao.getSetting(key);

      await settingsDao.setSetting(key, 'true', 'boolean');
      final after = await settingsDao.getSetting(key);

      // Then
      expect(before!.value, 'false');
      expect(after!.value, 'true');
    });
  });

  group('SettingsDao - Edge Cases', () {
    test('Given empty string value, When stored, Then should be retrievable', () async {
      // Given
      const key = 'empty_test';
      const value = '';
      const type = 'string';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.value, '');
    });

    test('Given special characters in value, When stored, Then should be preserved', () async {
      // Given
      const key = 'special_chars';
      const value = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
      const type = 'string';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.value, value);
    });

    test('Given very long value, When stored, Then should be preserved', () async {
      // Given
      const key = 'long_value';
      final value = 'a' * 1000; // 1000 character string
      const type = 'string';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.value.length, 1000);
      expect(retrieved.value, value);
    });

    test('Given Unicode characters, When stored, Then should be preserved', () async {
      // Given
      const key = 'unicode_test';
      const value = '你好世界 🌍 مرحبا';
      const type = 'string';

      // When
      await settingsDao.setSetting(key, value, type);
      final retrieved = await settingsDao.getSetting(key);

      // Then
      expect(retrieved!.value, value);
    });
  });

  group('SettingsDao - Timestamp Tracking', () {
    test('Given setting created, When retrieved, Then should have updatedAt timestamp', () async {
      // Given
      const key = 'timestamp_test';
      final beforeTime = DateTime.now().millisecondsSinceEpoch;

      // When
      await settingsDao.setSetting(key, 'value', 'string');
      final retrieved = await settingsDao.getSetting(key);
      final afterTime = DateTime.now().millisecondsSinceEpoch;

      // Then
      expect(retrieved!.updatedAt, greaterThanOrEqualTo(beforeTime));
      expect(retrieved.updatedAt, lessThanOrEqualTo(afterTime));
    });

    test('Given setting updated, When retrieved, Then updatedAt should be newer', () async {
      // Given
      const key = 'update_timestamp';
      await settingsDao.setSetting(key, 'old', 'string');
      final firstUpdate = (await settingsDao.getSetting(key))!.updatedAt;

      // Wait a bit to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 10));

      // When
      await settingsDao.setSetting(key, 'new', 'string');
      final secondUpdate = (await settingsDao.getSetting(key))!.updatedAt;

      // Then
      expect(secondUpdate, greaterThan(firstUpdate));
    });
  });

  group('SettingsDao - Upsert Behavior', () {
    test('Given non-existent key, When set, Then should insert', () async {
      // Given
      const key = 'unique_new_key';
      final beforeCount = (await settingsDao.getAllSettings()).length;

      // When
      await settingsDao.setSetting(key, 'value', 'string');
      final afterCount = (await settingsDao.getAllSettings()).length;
      final setting = await settingsDao.getSetting(key);

      // Then
      expect(afterCount, beforeCount + 1);
      expect(setting!.key, key);
      expect(setting.value, 'value');
    });

    test('Given existing key, When set, Then should update not duplicate', () async {
      // Given
      const key = 'unique_duplicate_test';
      await settingsDao.setSetting(key, 'first', 'string');
      final afterFirstInsert = (await settingsDao.getAllSettings()).length;

      // When
      await settingsDao.setSetting(key, 'second', 'string');
      final afterSecondInsert = (await settingsDao.getAllSettings()).length;
      final setting = await settingsDao.getSetting(key);

      // Then
      expect(afterSecondInsert, afterFirstInsert); // Count should stay the same
      expect(setting!.value, 'second'); // Value should be updated
    });
  });
}
