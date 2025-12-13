/**
 * Interval Service - Manages notification intervals and tracking
 */

import { v4 as uuidv4 } from 'uuid';
import { databaseService } from '../database/DatabaseService';
import type { Interval, CreateIntervalInput, CompleteIntervalInput } from '../../models/Interval';

export interface IIntervalService {
  createInterval(input: CreateIntervalInput): Promise<Interval>;
  completeInterval(input: CompleteIntervalInput): Promise<Interval>;
  getNextInterval(): Promise<Interval | null>;
  getIntervalsByDateRange(startDate: Date, endDate: Date): Promise<Interval[]>;
  getCompletionRate(date: Date): Promise<number>;
  getRecentSkippedCount(hours: number): Promise<number>;
}

class IntervalService implements IIntervalService {
  async createInterval(input: CreateIntervalInput): Promise<Interval> {
    const now = Date.now();
    const interval: Interval = {
      id: uuidv4(),
      scheduledTime: input.scheduledTime,
      intervalDuration: input.intervalDuration,
      isCompleted: false,
      createdAt: now,
    };

    await databaseService.executeSql(
      `INSERT INTO intervals (
        id, scheduled_time, actual_time, response_time, response_type,
        log_id, interval_duration, is_completed, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        interval.id,
        interval.scheduledTime,
        null,
        null,
        null,
        null,
        interval.intervalDuration,
        interval.isCompleted ? 1 : 0,
        interval.createdAt,
      ]
    );

    return interval;
  }

  async completeInterval(input: CompleteIntervalInput): Promise<Interval> {
    const actualTime = Date.now();

    await databaseService.executeSql(
      `UPDATE intervals
       SET actual_time = ?, response_time = ?, response_type = ?,
           log_id = ?, is_completed = 1
       WHERE id = ?`,
      [actualTime, input.responseTime, input.responseType, input.logId || null, input.id]
    );

    const interval = await this.getIntervalById(input.id);
    if (!interval) throw new Error('Interval not found after update');

    return interval;
  }

  async getNextInterval(): Promise<Interval | null> {
    const results = await databaseService.executeSql(
      `SELECT * FROM intervals
       WHERE is_completed = 0 AND scheduled_time > ?
       ORDER BY scheduled_time ASC
       LIMIT 1`,
      [Date.now()]
    );

    if (results.length === 0) return null;

    return this.mapRowToInterval(results[0]);
  }

  async getIntervalsByDateRange(startDate: Date, endDate: Date): Promise<Interval[]> {
    const startTs = startDate.getTime();
    const endTs = endDate.getTime();

    const results = await databaseService.executeSql(
      `SELECT * FROM intervals
       WHERE scheduled_time >= ? AND scheduled_time <= ?
       ORDER BY scheduled_time DESC`,
      [startTs, endTs]
    );

    return results.map((row) => this.mapRowToInterval(row));
  }

  async getCompletionRate(date: Date): Promise<number> {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    const results = await databaseService.executeSql(
      `SELECT
         COUNT(*) as total,
         COUNT(CASE WHEN response_type = 'logged' THEN 1 END) as logged
       FROM intervals
       WHERE scheduled_time >= ? AND scheduled_time <= ?`,
      [startOfDay.getTime(), endOfDay.getTime()]
    );

    if (results.length === 0 || results[0].total === 0) return 0;

    return results[0].logged / results[0].total;
  }

  async getRecentSkippedCount(hours: number): Promise<number> {
    const cutoffTime = Date.now() - hours * 60 * 60 * 1000;

    const results = await databaseService.executeSql(
      `SELECT COUNT(*) as count
       FROM intervals
       WHERE response_type = 'skipped' AND response_time >= ?`,
      [cutoffTime]
    );

    return results[0]?.count || 0;
  }

  private async getIntervalById(id: string): Promise<Interval | null> {
    const results = await databaseService.executeSql('SELECT * FROM intervals WHERE id = ?', [id]);

    if (results.length === 0) return null;

    return this.mapRowToInterval(results[0]);
  }

  private mapRowToInterval(row: any): Interval {
    return {
      id: row.id,
      scheduledTime: row.scheduled_time,
      actualTime: row.actual_time || undefined,
      responseTime: row.response_time || undefined,
      responseType: row.response_type || undefined,
      logId: row.log_id || undefined,
      intervalDuration: row.interval_duration,
      isCompleted: row.is_completed === 1,
      createdAt: row.created_at,
    };
  }
}

export const intervalService = new IntervalService();
