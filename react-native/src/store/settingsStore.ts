/**
 * Settings Store - Zustand state management for app settings
 */

import { create } from 'zustand';
import type { AppSettings } from '../models/Settings';
import { settingsService } from '../services/settings/SettingsService';

interface SettingsStore {
  // State
  settings: AppSettings | null;
  isLoading: boolean;
  error: string | null;

  // Actions
  loadSettings: () => Promise<void>;
  updateSetting: <K extends keyof AppSettings>(key: K, value: AppSettings[K]) => Promise<void>;
  updateSettings: (updates: Partial<AppSettings>) => Promise<void>;
  resetSettings: () => Promise<void>;
  getSetting: <K extends keyof AppSettings>(key: K) => AppSettings[K] | null;
}

export const useSettingsStore = create<SettingsStore>((set, get) => ({
  // Initial state
  settings: null,
  isLoading: false,
  error: null,

  // Load all settings
  loadSettings: async () => {
    try {
      set({ isLoading: true, error: null });
      const settings = await settingsService.getSettings();
      set({ settings, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to load settings',
        isLoading: false,
      });
    }
  },

  // Update a single setting
  updateSetting: async <K extends keyof AppSettings>(key: K, value: AppSettings[K]) => {
    try {
      set({ isLoading: true, error: null });
      await settingsService.setSetting(key, value);

      // Update in state
      const currentSettings = get().settings;
      if (currentSettings) {
        set({
          settings: { ...currentSettings, [key]: value },
          isLoading: false,
        });
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to update setting',
        isLoading: false,
      });
      throw error;
    }
  },

  // Update multiple settings
  updateSettings: async (updates: Partial<AppSettings>) => {
    try {
      set({ isLoading: true, error: null });
      await settingsService.updateSettings(updates);

      // Update in state
      const currentSettings = get().settings;
      if (currentSettings) {
        set({
          settings: { ...currentSettings, ...updates },
          isLoading: false,
        });
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to update settings',
        isLoading: false,
      });
      throw error;
    }
  },

  // Reset to defaults
  resetSettings: async () => {
    try {
      set({ isLoading: true, error: null });
      await settingsService.resetSettings();
      const settings = await settingsService.getSettings();
      set({ settings, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to reset settings',
        isLoading: false,
      });
      throw error;
    }
  },

  // Get a specific setting
  getSetting: <K extends keyof AppSettings>(key: K): AppSettings[K] | null => {
    const settings = get().settings;
    return settings ? settings[key] : null;
  },
}));
