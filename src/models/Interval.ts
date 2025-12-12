/**
 * Interval model and related types
 */

export type ResponseType = 'logged' | 'skipped' | 'ignored';

export interface Interval {
  id: string;
  scheduledTime: number; // When should fire
  actualTime?: number; // When actually fired
  responseTime?: number; // User response time
  responseType?: ResponseType;
  logId?: string; // FK to Log
  intervalDuration: number; // 900000 or 1800000 ms
  isCompleted: boolean;
  createdAt: number;
}

export interface CreateIntervalInput {
  scheduledTime: number;
  intervalDuration: number;
}

export interface CompleteIntervalInput {
  id: string;
  responseType: ResponseType;
  responseTime: number;
  logId?: string;
}
