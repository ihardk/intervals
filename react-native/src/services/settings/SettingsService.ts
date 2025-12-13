/**
 * Settings Service - Handles app settings persistence
 */

import { databaseService } from '../database/DatabaseService';
import type { AppSettings, SettingType } from '../../models/Settings';
import { DEFAULT_SETTINGS } from '../../models/Settings';

export interface ISettingsService {
  getSettings(): Promise<AppSettings>;
  getSetting<K extends keyof AppSettings>(key: K): Promise<AppSettings[K]>;
  setSetting<K extends keyof AppSettings>(key: K, value: AppSettings[K]): Promise<void>;
  updateSettings(settings: Partial<AppSettings>): Promise<void>;
  resetSettings(): Promise<void>;
  getIntervalDuration(): Promise<number>;
  setIntervalDuration(durationMs: number): Promise<void>;
}

class SettingsService implements ISettingsService {
  // Map between camelCase (model) and snake_case (database)
  private readonly keyMap: Record<keyof AppSettings, string> = {
    intervalDuration: 'interval_duration',
    notificationsEnabled: 'notifications_enabled',
    voiceEnabled: 'voice_enabled',
    theme: 'theme',
    dailyReminderTime: 'daily_reminder_time',
    autoCategorize: 'auto_categorize',
    onboardingCompleted: 'onboarding_completed',
  };

  private readonly reverseKeyMap: Record<string, keyof AppSettings> = {
    interval_duration: 'intervalDuration',
    notifications_enabled: 'notificationsEnabled',
    voice_enabled: 'voiceEnabled',
    theme: 'theme',
    daily_reminder_time: 'dailyReminderTime',
    auto_categorize: 'autoCategorize',
    onboarding_completed: 'onboardingCompleted',
  };

  async getSettings(): Promise<AppSettings> {
    const results = await databaseService.executeSql('SELECT * FROM settings');

    const settings: Partial<AppSettings> = {};

    for (const row of results) {
      const dbKey = row.key as string;
      const modelKey = this.reverseKeyMap[dbKey];
      if (modelKey) {
        settings[modelKey] = this.parseValue(row.value, row.type);
      }
    }

    // Merge with defaults for any missing keys
    return { ...DEFAULT_SETTINGS, ...settings };
  }

  async getSetting<K extends keyof AppSettings>(key: K): Promise<AppSettings[K]> {
    const dbKey = this.keyMap[key];
    const results = await databaseService.executeSql(
      'SELECT value, type FROM settings WHERE key = ?',
      [dbKey]
    );

    if (results.length === 0) {
      return DEFAULT_SETTINGS[key];
    }

    return this.parseValue(results[0].value, results[0].type) as AppSettings[K];
  }

  async setSetting<K extends keyof AppSettings>(key: K, value: AppSettings[K]): Promise<void> {
    const dbKey = this.keyMap[key];
    const type = this.getSettingType(value);
    const stringValue = this.stringifyValue(value);
    const now = Date.now();

    // Check if setting exists
    const existing = await databaseService.executeSql(
      'SELECT key FROM settings WHERE key = ?',
      [dbKey]
    );

    if (existing.length > 0) {
      // Update
      await databaseService.executeSql(
        'UPDATE settings SET value = ?, type = ?, updated_at = ? WHERE key = ?',
        [stringValue, type, now, dbKey]
      );
    } else {
      // Insert
      await databaseService.executeSql(
        'INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)',
        [dbKey, stringValue, type, now]
      );
    }
  }

  async updateSettings(settings: Partial<AppSettings>): Promise<void> {
    const statements = Object.entries(settings).map(([modelKey, value]) => {
      const dbKey = this.keyMap[modelKey as keyof AppSettings];
      const type = this.getSettingType(value);
      const stringValue = this.stringifyValue(value);
      const now = Date.now();

      return {
        sql: `
          INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)
          ON CONFLICT(key) DO UPDATE SET value = ?, type = ?, updated_at = ?
        `,
        params: [dbKey, stringValue, type, now, stringValue, type, now],
      };
    });

    await databaseService.transaction(statements);
  }

  async resetSettings(): Promise<void> {
    const now = Date.now();
    const statements = Object.entries(DEFAULT_SETTINGS).map(([modelKey, value]) => {
      const dbKey = this.keyMap[modelKey as keyof AppSettings];
      const type = this.getSettingType(value);
      const stringValue = this.stringifyValue(value);

      return {
        sql: 'UPDATE settings SET value = ?, type = ?, updated_at = ? WHERE key = ?',
        params: [stringValue, type, now, dbKey],
      };
    });

    await databaseService.transaction(statements);
  }

  async getIntervalDuration(): Promise<number> {
    return (await this.getSetting('intervalDuration')) as number;
  }

  async setIntervalDuration(durationMs: number): Promise<void> {
    if (durationMs !== 900000 && durationMs !== 1800000) {
      throw new Error('Invalid interval duration. Must be 900000 (15min) or 1800000 (30min)');
    }

    await this.setSetting('intervalDuration', durationMs);
  }

  private parseValue(value: string, type: SettingType): any {
    switch (type) {
      case 'number':
        return Number(value);
      case 'boolean':
        return value === 'true';
      case 'json':
        return JSON.parse(value);
      case 'string':
      default:
        return value;
    }
  }

  private stringifyValue(value: any): string {
    if (typeof value === 'object') {
      return JSON.stringify(value);
    }
    return String(value);
  }

  private getSettingType(value: any): SettingType {
    if (typeof value === 'number') return 'number';
    if (typeof value === 'boolean') return 'boolean';
    if (typeof value === 'object') return 'json';
    return 'string';
  }
}

export const settingsService = new SettingsService();
