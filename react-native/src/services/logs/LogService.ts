import { v4 as uuidv4 } from 'uuid';
import { endOfDay, startOfDay } from 'date-fns';
import type { CreateLogInput, Log, UpdateLogInput } from '../../models/Log';
import { databaseService } from '../database/DatabaseService';

const ROW_TO_LOG = (row: any): Log => ({
  id: row.id,
  timestamp: row.timestamp,
  content: row.content,
  entryType: row.entry_type,
  audioPath: row.audio_path || undefined,
  transcriptionStatus: row.transcription_status,
  category: row.category || undefined,
  tags: row.tags ? JSON.parse(row.tags) : undefined,
  mood: row.mood || undefined,
  createdAt: row.created_at,
  updatedAt: row.updated_at,
  isDeleted: row.is_deleted === 1,
  metadata: row.metadata ? JSON.parse(row.metadata) : undefined,
});

class LogService {
  async getTodayLogs(): Promise<Log[]> {
    const start = startOfDay(new Date()).getTime();
    const end = endOfDay(new Date()).getTime();
    return this.getLogsByDateRange(new Date(start), new Date(end));
  }

  async getLogsByDateRange(start: Date, end: Date): Promise<Log[]> {
    const rows = await databaseService.executeSql(
      `SELECT * FROM logs
       WHERE is_deleted = 0
         AND timestamp BETWEEN ? AND ?
       ORDER BY timestamp DESC`,
      [start.getTime(), end.getTime()]
    );
    return rows.map(ROW_TO_LOG);
  }

  async createLog(input: CreateLogInput): Promise<Log> {
    const now = Date.now();
    const id = uuidv4();
    const timestamp = input.timestamp ?? now;

    await databaseService.executeSql(
      `INSERT INTO logs (
        id, timestamp, content, entry_type, audio_path, transcription_status,
        category, tags, mood, created_at, updated_at, is_deleted, metadata
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?)`,
      [
        id,
        timestamp,
        input.content,
        input.entryType,
        input.audioPath ?? null,
        'complete',
        input.category ?? null,
        input.tags ? JSON.stringify(input.tags) : null,
        input.mood ?? null,
        now,
        now,
        null,
      ]
    );

    return {
      id,
      timestamp,
      content: input.content,
      entryType: input.entryType,
      audioPath: input.audioPath,
      transcriptionStatus: 'complete',
      category: input.category,
      tags: input.tags,
      mood: input.mood,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      metadata: undefined,
    };
  }

  async updateLog(input: UpdateLogInput): Promise<Log> {
    const now = Date.now();
    const fields: string[] = [];
    const params: any[] = [];

    if (input.content !== undefined) {
      fields.push('content = ?');
      params.push(input.content);
    }
    if (input.category !== undefined) {
      fields.push('category = ?');
      params.push(input.category);
    }
    if (input.tags !== undefined) {
      fields.push('tags = ?');
      params.push(JSON.stringify(input.tags));
    }
    if (input.mood !== undefined) {
      fields.push('mood = ?');
      params.push(input.mood);
    }

    fields.push('updated_at = ?');
    params.push(now, input.id);

    await databaseService.executeSql(
      `UPDATE logs SET ${fields.join(', ')} WHERE id = ?`,
      params
    );

    const rows = await databaseService.executeSql(
      `SELECT * FROM logs WHERE id = ? LIMIT 1`,
      [input.id]
    );

    if (!rows[0]) {
      throw new Error('Log not found after update');
    }

    return ROW_TO_LOG(rows[0]);
  }

  async deleteLog(id: string): Promise<void> {
    const now = Date.now();
    await databaseService.executeSql(
      `UPDATE logs SET is_deleted = 1, updated_at = ? WHERE id = ?`,
      [now, id]
    );
  }
}

export const logService = new LogService();

