/**
 * Insight Service - Generate insights and detect patterns
 */

import { v4 as uuidv4 } from 'uuid';
import { databaseService } from '../database/DatabaseService';
import { logService } from '../logs/LogService';
import { intervalService } from '../intervals/IntervalService';
import { streakService } from '../streaks/StreakService';
import type { Insight, InsightData, PatternDetectionResult, ActivityCount } from '../../models/Insight';
import { format, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns';

export interface IInsightService {
  generateDailyInsight(date: Date): Promise<Insight>;
  generateWeeklyInsight(weekStartDate: Date): Promise<Insight>;
  generateMonthlyInsight(month: number, year: number): Promise<Insight>;
  getInsight(type: string, date: string): Promise<Insight | null>;
  detectPatterns(startDate: Date, endDate: Date): Promise<PatternDetectionResult>;
  calculateProductivityScore(startDate: Date, endDate: Date): Promise<number>;
  getTopActivities(startDate: Date, endDate: Date, limit: number): Promise<ActivityCount[]>;
}

class InsightService implements IInsightService {
  /**
   * Generate daily insight for a specific date
   */
  async generateDailyInsight(date: Date): Promise<Insight> {
    const dateStr = format(date, 'yyyy-MM-dd');

    // Check cache first
    const cached = await this.getInsight('daily', dateStr);
    if (cached) return cached;

    // Get logs for the day
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    const logs = await logService.getLogsByDateRange(startOfDay, endOfDay);

    // Get intervals for completion rate
    const intervals = await intervalService.getIntervalsByDateRange(startOfDay, endOfDay);
    const completionRate = intervals.length > 0
      ? intervals.filter((i) => i.responseType === 'logged').length / intervals.length
      : 0;

    // Get streak
    const streakDays = await streakService.getCurrentStreak();

    // Get top activities
    const topActivities = await this.getTopActivities(startOfDay, endOfDay, 5);

    // Detect patterns
    const patterns = await this.detectPatterns(startOfDay, endOfDay);

    // Calculate productivity score
    const productivityScore = await this.calculateProductivityScore(startOfDay, endOfDay);

    const data: InsightData = {
      totalLogs: logs.length,
      skippedIntervals: intervals.filter((i) => i.responseType === 'skipped').length,
      completionRate,
      streakDays,
      topActivities,
      productivityScore,
      peakHours: patterns.peakHours,
      distractionPeriods: patterns.distractionPeriods,
    };

    const insight = await this.saveInsight('daily', dateStr, data);
    return insight;
  }

  /**
   * Generate weekly insight
   */
  async generateWeeklyInsight(weekStartDate: Date): Promise<Insight> {
    const start = startOfWeek(weekStartDate, { weekStartsOn: 1 }); // Monday
    const end = endOfWeek(weekStartDate, { weekStartsOn: 1 }); // Sunday
    const dateStr = format(start, 'yyyy-MM-dd');

    const logs = await logService.getLogsByDateRange(start, end);
    const topActivities = await this.getTopActivities(start, end, 10);
    const patterns = await this.detectPatterns(start, end);
    const productivityScore = await this.calculateProductivityScore(start, end);

    const data: InsightData = {
      totalLogs: logs.length,
      skippedIntervals: 0, // Calculate from intervals
      completionRate: 0, // Calculate from intervals
      streakDays: await streakService.getCurrentStreak(),
      topActivities,
      productivityScore,
      peakHours: patterns.peakHours,
      distractionPeriods: patterns.distractionPeriods,
    };

    return this.saveInsight('weekly', dateStr, data);
  }

  /**
   * Generate monthly insight
   */
  async generateMonthlyInsight(month: number, year: number): Promise<Insight> {
    const date = new Date(year, month - 1, 1);
    const start = startOfMonth(date);
    const end = endOfMonth(date);
    const dateStr = format(start, 'yyyy-MM-dd');

    const logs = await logService.getLogsByDateRange(start, end);
    const topActivities = await this.getTopActivities(start, end, 10);
    const patterns = await this.detectPatterns(start, end);
    const productivityScore = await this.calculateProductivityScore(start, end);

    const data: InsightData = {
      totalLogs: logs.length,
      skippedIntervals: 0,
      completionRate: 0,
      streakDays: await streakService.getCurrentStreak(),
      topActivities,
      productivityScore,
      peakHours: patterns.peakHours,
      distractionPeriods: patterns.distractionPeriods,
    };

    return this.saveInsight('monthly', dateStr, data);
  }

  /**
   * Get cached insight or null
   */
  async getInsight(type: string, date: string): Promise<Insight | null> {
    const results = await databaseService.executeSql(
      `SELECT * FROM insights
       WHERE insight_type = ? AND date = ?
       LIMIT 1`,
      [type, date]
    );

    if (results.length === 0) return null;

    return this.mapRowToInsight(results[0]);
  }

  /**
   * Detect patterns in user's activity
   */
  async detectPatterns(startDate: Date, endDate: Date): Promise<PatternDetectionResult> {
    const logs = await logService.getLogsByDateRange(startDate, endDate);

    // Peak hours analysis
    const hourCounts: Record<number, number> = {};
    logs.forEach((log) => {
      const hour = new Date(log.timestamp).getHours();
      hourCounts[hour] = (hourCounts[hour] || 0) + 1;
    });

    const avgCount = logs.length / 24;
    const peakHours = Object.entries(hourCounts)
      .filter(([_, count]) => count > avgCount * 1.5)
      .map(([hour]) => parseInt(hour))
      .sort((a, b) => a - b);

    // Distraction periods (hours with high distraction category logs)
    const distractionLogs = logs.filter((log) =>
      log.category?.toLowerCase().includes('distraction')
    );
    const distractionHours: Record<number, number> = {};
    distractionLogs.forEach((log) => {
      const hour = new Date(log.timestamp).getHours();
      distractionHours[hour] = (distractionHours[hour] || 0) + 1;
    });

    const distractionPeriods = Object.entries(distractionHours)
      .filter(([_, count]) => count >= 2)
      .map(([hour]) => parseInt(hour))
      .sort((a, b) => a - b);

    // Recurring activities
    const activityCounts: Record<string, number> = {};
    logs.forEach((log) => {
      const words = log.content.toLowerCase().split(' ');
      words.forEach((word) => {
        if (word.length > 4) {
          activityCounts[word] = (activityCounts[word] || 0) + 1;
        }
      });
    });

    const recurringActivities = Object.entries(activityCounts)
      .filter(([_, count]) => count >= 3)
      .sort(([_, a], [__, b]) => b - a)
      .slice(0, 10)
      .map(([word]) => word);

    // Time distribution by category
    const timeDistribution: Record<string, number> = {};
    logs.forEach((log) => {
      if (log.category) {
        timeDistribution[log.category] = (timeDistribution[log.category] || 0) + 1;
      }
    });

    return {
      peakHours,
      distractionPeriods,
      recurringActivities,
      timeDistribution,
    };
  }

  /**
   * Calculate productivity score (0-1)
   */
  async calculateProductivityScore(startDate: Date, endDate: Date): Promise<number> {
    const logs = await logService.getLogsByDateRange(startDate, endDate);

    if (logs.length === 0) return 0;

    // Count productive vs non-productive logs
    const productiveCategories = ['work', 'learning'];
    const distractedCategories = ['distraction', 'social'];

    const productiveLogs = logs.filter((log) =>
      productiveCategories.some((cat) => log.category?.toLowerCase().includes(cat))
    ).length;

    const distractedLogs = logs.filter((log) =>
      distractedCategories.some((cat) => log.category?.toLowerCase().includes(cat))
    ).length;

    // Calculate score
    const productiveRatio = productiveLogs / logs.length;
    const distractedRatio = distractedLogs / logs.length;

    const score = Math.max(0, Math.min(1, productiveRatio - distractedRatio * 0.5));

    return Math.round(score * 100) / 100;
  }

  /**
   * Get top activities
   */
  async getTopActivities(
    startDate: Date,
    endDate: Date,
    limit: number
  ): Promise<ActivityCount[]> {
    const logs = await logService.getLogsByDateRange(startDate, endDate);

    const categoryCounts: Record<string, number> = {};
    logs.forEach((log) => {
      if (log.category) {
        categoryCounts[log.category] = (categoryCounts[log.category] || 0) + 1;
      }
    });

    return Object.entries(categoryCounts)
      .map(([activity, count]) => ({ activity, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, limit);
  }

  /**
   * Save insight to database
   */
  private async saveInsight(
    type: string,
    date: string,
    data: InsightData
  ): Promise<Insight> {
    const now = Date.now();
    const expiresAt = now + 24 * 60 * 60 * 1000; // 24 hours

    const insight: Insight = {
      id: uuidv4(),
      insightType: type as any,
      date,
      data,
      createdAt: now,
      expiresAt,
    };

    await databaseService.executeSql(
      `INSERT OR REPLACE INTO insights (
        id, insight_type, date, data, created_at, expires_at
      ) VALUES (?, ?, ?, ?, ?, ?)`,
      [insight.id, insight.insightType, insight.date, JSON.stringify(insight.data), insight.createdAt, insight.expiresAt]
    );

    return insight;
  }

  /**
   * Map database row to Insight
   */
  private mapRowToInsight(row: any): Insight {
    return {
      id: row.id,
      insightType: row.insight_type,
      date: row.date,
      data: JSON.parse(row.data),
      createdAt: row.created_at,
      expiresAt: row.expires_at || undefined,
    };
  }
}

export const insightService = new InsightService();
