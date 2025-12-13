import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

/// Data Access Object for Settings table
/// Provides key-value storage for app settings
@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Get a setting by key
  Future<SettingData?> getSetting(String key) {
    return (select(settings)..where((s) => s.key.equals(key))).getSingleOrNull();
  }

  /// Get all settings
  Future<List<SettingData>> getAllSettings() {
    return select(settings).get();
  }

  /// Set a setting value
  Future<void> setSetting(String key, String value, String type) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: key,
        value: value,
        type: type,
        updatedAt: now,
      ),
    );
  }

  /// Delete a setting
  Future<int> deleteSetting(String key) {
    return (delete(settings)..where((s) => s.key.equals(key))).go();
  }

  /// Update multiple settings
  Future<void> updateSettings(Map<String, ({String value, String type})> settingsMap) async {
    await batch((batch) {
      for (final entry in settingsMap.entries) {
        batch.insert(
          settings,
          SettingsCompanion.insert(
            key: entry.key,
            value: entry.value.value,
            type: entry.value.type,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Watch a setting for changes
  Stream<SettingData?> watchSetting(String key) {
    return (select(settings)..where((s) => s.key.equals(key))).watchSingleOrNull();
  }

  /// Watch all settings
  Stream<List<SettingData>> watchAllSettings() {
    return select(settings).watch();
  }

  /// Reset all settings to defaults
  Future<void> resetAllSettings() async {
    await delete(settings).go();
    // Default settings will be re-inserted by the database initialization
  }
}
