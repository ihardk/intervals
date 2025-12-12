/**
 * Logs Store - Zustand state management for logs
 */

import { create } from 'zustand';
import type { Log, CreateLogInput, UpdateLogInput } from '../models/Log';
import { logService } from '../services/logs/LogService';
import { categoryService } from '../services/categories/CategoryService';
import { settingsService } from '../services/settings/SettingsService';

interface LogsStore {
  // State
  logs: Log[];
  currentLog: Log | null;
  isLoading: boolean;
  error: string | null;

  // Actions
  fetchTodayLogs: () => Promise<void>;
  fetchLogsByDateRange: (start: Date, end: Date) => Promise<void>;
  createLog: (input: CreateLogInput) => Promise<Log>;
  updateLog: (input: UpdateLogInput) => Promise<Log>;
  deleteLog: (id: string) => Promise<void>;
  setCurrentLog: (log: Log | null) => void;
  clearError: () => void;
  refreshLogs: () => Promise<void>;
}

export const useLogsStore = create<LogsStore>((set, get) => ({
  // Initial state
  logs: [],
  currentLog: null,
  isLoading: false,
  error: null,

  // Fetch today's logs
  fetchTodayLogs: async () => {
    try {
      set({ isLoading: true, error: null });
      const logs = await logService.getTodayLogs();
      set({ logs, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch logs',
        isLoading: false,
      });
    }
  },

  // Fetch logs by date range
  fetchLogsByDateRange: async (start: Date, end: Date) => {
    try {
      set({ isLoading: true, error: null });
      const logs = await logService.getLogsByDateRange(start, end);
      set({ logs, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch logs',
        isLoading: false,
      });
    }
  },

  // Create a new log
  createLog: async (input: CreateLogInput) => {
    try {
      set({ isLoading: true, error: null });

      // Auto-categorize if enabled
      const settings = await settingsService.getSettings();
      if (settings.autoCategorize && !input.category) {
        const category = await categoryService.categorizeLog(input.content);
        if (category) {
          input.category = category;
        }
      }

      const log = await logService.createLog(input);

      // Add to current logs
      const currentLogs = get().logs;
      set({ logs: [log, ...currentLogs], isLoading: false });

      return log;
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to create log',
        isLoading: false,
      });
      throw error;
    }
  },

  // Update a log
  updateLog: async (input: UpdateLogInput) => {
    try {
      set({ isLoading: true, error: null });
      const updatedLog = await logService.updateLog(input);

      // Update in state
      const currentLogs = get().logs;
      const updatedLogs = currentLogs.map((log) =>
        log.id === updatedLog.id ? updatedLog : log
      );
      set({ logs: updatedLogs, isLoading: false });

      return updatedLog;
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to update log',
        isLoading: false,
      });
      throw error;
    }
  },

  // Delete a log (soft delete)
  deleteLog: async (id: string) => {
    try {
      set({ isLoading: true, error: null });
      await logService.deleteLog(id);

      // Remove from state
      const currentLogs = get().logs;
      const filteredLogs = currentLogs.filter((log) => log.id !== id);
      set({ logs: filteredLogs, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to delete log',
        isLoading: false,
      });
      throw error;
    }
  },

  // Set current log
  setCurrentLog: (log: Log | null) => {
    set({ currentLog: log });
  },

  // Clear error
  clearError: () => {
    set({ error: null });
  },

  // Refresh logs
  refreshLogs: async () => {
    await get().fetchTodayLogs();
  },
}));
