/**
 * Streak Service - Track user consistency and streaks
 */

import { v4 as uuidv4 } from 'uuid';
import { databaseService } from '../database/DatabaseService';
import { logService } from '../logs/LogService';
import { format, startOfDay, differenceInDays } from 'date-fns';

export interface Streak {
  id: string;
  streakType: 'daily_logs' | 'consistent_intervals' | 'no_skip';
  startDate: string; // ISO date
  endDate?: string; // ISO date (null if ongoing)
  currentCount: number;
  bestCount: number;
  isActive: boolean;
  createdAt: number;
  updatedAt: number;
}

export interface IStreakService {
  getCurrentStreak(): Promise<number>;
  getBestStreak(): Promise<number>;
  updateStreak(): Promise<void>;
  isStreakActive(): Promise<boolean>;
}

class StreakService implements IStreakService {
  /**
   * Get current active streak count
   */
  async getCurrentStreak(): Promise<number> {
    const streak = await this.getActiveStreak();
    return streak?.currentCount || 0;
  }

  /**
   * Get best streak ever achieved
   */
  async getBestStreak(): Promise<number> {
    const results = await databaseService.executeSql(
      `SELECT MAX(best_count) as best
       FROM streaks
       WHERE streak_type = 'daily_logs'`
    );

    return results[0]?.best || 0;
  }

  /**
   * Update streak based on today's activity
   */
  async updateStreak(): Promise<void> {
    const today = startOfDay(new Date());
    const todayStr = format(today, 'yyyy-MM-dd');

    // Get today's logs
    const todayLogs = await logService.getTodayLogs();

    // Get or create active streak
    let streak = await this.getActiveStreak();

    if (todayLogs.length > 0) {
      // User logged today
      if (!streak) {
        // Start new streak
        streak = await this.createStreak(todayStr);
      } else {
        // Check if we need to continue or break the streak
        const lastDate = new Date(streak.endDate || streak.startDate);
        const daysDiff = differenceInDays(today, lastDate);

        if (daysDiff === 0) {
          // Same day, streak continues (no update needed)
          return;
        } else if (daysDiff === 1) {
          // Next day, increment streak
          await this.incrementStreak(streak.id, todayStr);
        } else if (daysDiff > 1) {
          // Streak broken, start new one
          await this.endStreak(streak.id, format(lastDate, 'yyyy-MM-dd'));
          await this.createStreak(todayStr);
        }
      }
    } else {
      // No logs today
      if (streak) {
        const lastDate = new Date(streak.endDate || streak.startDate);
        const daysDiff = differenceInDays(today, lastDate);

        if (daysDiff > 1) {
          // Streak broken
          await this.endStreak(streak.id, format(lastDate, 'yyyy-MM-dd'));
        }
      }
    }
  }

  /**
   * Check if streak is currently active
   */
  async isStreakActive(): Promise<boolean> {
    const streak = await this.getActiveStreak();
    if (!streak) return false;

    const lastDate = new Date(streak.endDate || streak.startDate);
    const today = startOfDay(new Date());
    const daysDiff = differenceInDays(today, lastDate);

    // Active if logged today or yesterday
    return daysDiff <= 1;
  }

  /**
   * Get active streak
   */
  private async getActiveStreak(): Promise<Streak | null> {
    const results = await databaseService.executeSql(
      `SELECT * FROM streaks
       WHERE streak_type = 'daily_logs' AND is_active = 1
       ORDER BY created_at DESC
       LIMIT 1`
    );

    if (results.length === 0) return null;

    return this.mapRowToStreak(results[0]);
  }

  /**
   * Create a new streak
   */
  private async createStreak(startDate: string): Promise<Streak> {
    const now = Date.now();
    const streak: Streak = {
      id: uuidv4(),
      streakType: 'daily_logs',
      startDate,
      currentCount: 1,
      bestCount: 1,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    };

    await databaseService.executeSql(
      `INSERT INTO streaks (
        id, streak_type, start_date, end_date, current_count,
        best_count, is_active, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        streak.id,
        streak.streakType,
        streak.startDate,
        null,
        streak.currentCount,
        streak.bestCount,
        streak.isActive ? 1 : 0,
        streak.createdAt,
        streak.updatedAt,
      ]
    );

    return streak;
  }

  /**
   * Increment streak count
   */
  private async incrementStreak(streakId: string, newEndDate: string): Promise<void> {
    const now = Date.now();

    await databaseService.executeSql(
      `UPDATE streaks
       SET current_count = current_count + 1,
           best_count = MAX(best_count, current_count + 1),
           end_date = ?,
           updated_at = ?
       WHERE id = ?`,
      [newEndDate, now, streakId]
    );
  }

  /**
   * End a streak
   */
  private async endStreak(streakId: string, endDate: string): Promise<void> {
    const now = Date.now();

    await databaseService.executeSql(
      `UPDATE streaks
       SET is_active = 0,
           end_date = ?,
           updated_at = ?
       WHERE id = ?`,
      [endDate, now, streakId]
    );
  }

  /**
   * Map database row to Streak
   */
  private mapRowToStreak(row: any): Streak {
    return {
      id: row.id,
      streakType: row.streak_type,
      startDate: row.start_date,
      endDate: row.end_date || undefined,
      currentCount: row.current_count,
      bestCount: row.best_count,
      isActive: row.is_active === 1,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

export const streakService = new StreakService();
