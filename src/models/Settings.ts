/**
 * Settings model and related types
 */

export type SettingType = 'string' | 'number' | 'boolean' | 'json';

export interface Setting {
  key: string;
  value: string; // Stored as string
  type: SettingType;
  updatedAt: number;
}

export interface AppSettings {
  intervalDuration: number; // 900000 or 1800000
  notificationsEnabled: boolean;
  voiceEnabled: boolean;
  theme: 'dark' | 'light';
  dailyReminderTime: string; // HH:MM
  autoCategorize: boolean;
  onboardingCompleted: boolean;
}

export const DEFAULT_SETTINGS: AppSettings = {
  intervalDuration: 900000, // 15 minutes
  notificationsEnabled: true,
  voiceEnabled: true,
  theme: 'dark',
  dailyReminderTime: '20:00',
  autoCategorize: true,
  onboardingCompleted: false,
};
