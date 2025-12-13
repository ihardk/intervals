/**
 * Insight model and related types
 */

export type InsightType = 'daily' | 'weekly' | 'monthly' | 'pattern';

export interface Insight {
  id: string;
  insightType: InsightType;
  date: string; // ISO date YYYY-MM-DD
  data: InsightData;
  createdAt: number;
  expiresAt?: number;
}

export interface InsightData {
  totalLogs: number;
  skippedIntervals: number;
  completionRate: number;
  streakDays: number;
  topActivities: ActivityCount[];
  productivityScore?: number;
  peakHours?: number[];
  distractionPeriods?: number[];
}

export interface ActivityCount {
  activity: string;
  count: number;
}

export interface PatternDetectionResult {
  peakHours: number[];
  distractionPeriods: number[];
  recurringActivities: string[];
  timeDistribution: Record<string, number>;
}
