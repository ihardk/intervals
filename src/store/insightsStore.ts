/**
 * Insights Store - Zustand state management for insights
 */

import { create } from 'zustand';
import type { Insight } from '../models/Insight';
import { insightService } from '../services/insights/InsightService';
import { streakService } from '../services/streaks/StreakService';

interface InsightsStore {
  // State
  dailyInsight: Insight | null;
  weeklyInsight: Insight | null;
  monthlyInsight: Insight | null;
  currentStreak: number;
  bestStreak: number;
  isLoading: boolean;
  error: string | null;

  // Actions
  fetchDailyInsight: (date?: Date) => Promise<void>;
  fetchWeeklyInsight: (weekStart?: Date) => Promise<void>;
  fetchMonthlyInsight: (month: number, year: number) => Promise<void>;
  fetchStreakData: () => Promise<void>;
  clearInsights: () => void;
  refreshAll: () => Promise<void>;
}

export const useInsightsStore = create<InsightsStore>((set, get) => ({
  // Initial state
  dailyInsight: null,
  weeklyInsight: null,
  monthlyInsight: null,
  currentStreak: 0,
  bestStreak: 0,
  isLoading: false,
  error: null,

  // Fetch daily insight
  fetchDailyInsight: async (date = new Date()) => {
    try {
      set({ isLoading: true, error: null });
      const insight = await insightService.generateDailyInsight(date);
      set({ dailyInsight: insight, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch daily insight',
        isLoading: false,
      });
    }
  },

  // Fetch weekly insight
  fetchWeeklyInsight: async (weekStart = new Date()) => {
    try {
      set({ isLoading: true, error: null });
      const insight = await insightService.generateWeeklyInsight(weekStart);
      set({ weeklyInsight: insight, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch weekly insight',
        isLoading: false,
      });
    }
  },

  // Fetch monthly insight
  fetchMonthlyInsight: async (month: number, year: number) => {
    try {
      set({ isLoading: true, error: null });
      const insight = await insightService.generateMonthlyInsight(month, year);
      set({ monthlyInsight: insight, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch monthly insight',
        isLoading: false,
      });
    }
  },

  // Fetch streak data
  fetchStreakData: async () => {
    try {
      const currentStreak = await streakService.getCurrentStreak();
      const bestStreak = await streakService.getBestStreak();
      set({ currentStreak, bestStreak });
    } catch (error) {
      console.error('Failed to fetch streak data:', error);
    }
  },

  // Clear all insights
  clearInsights: () => {
    set({
      dailyInsight: null,
      weeklyInsight: null,
      monthlyInsight: null,
      error: null,
    });
  },

  // Refresh all data
  refreshAll: async () => {
    await get().fetchDailyInsight();
    await get().fetchStreakData();
  },
}));
