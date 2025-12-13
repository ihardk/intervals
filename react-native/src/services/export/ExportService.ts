/**
 * Export Service - Export logs to CSV and JSON
 */

import { v4 as uuidv4 } from 'uuid';
import RNFS from 'react-native-fs';
import { Share } from 'react-native';
import { databaseService } from '../database/DatabaseService';
import { logService } from '../logs/LogService';
import { format } from 'date-fns';
import type { Log } from '../../models/Log';

export interface ExportRecord {
  id: string;
  exportType: 'csv' | 'json';
  dateRangeStart: string;
  dateRangeEnd: string;
  filePath: string;
  fileSize: number;
  recordCount: number;
  createdAt: number;
}

export interface IExportService {
  exportToCSV(startDate: Date, endDate: Date): Promise<string>;
  exportToJSON(startDate: Date, endDate: Date): Promise<string>;
  shareExport(filePath: string): Promise<void>;
  getExportHistory(): Promise<ExportRecord[]>;
}

class ExportService implements IExportService {
  private exportDir = `${RNFS.DocumentDirectoryPath}/exports`;

  /**
   * Export logs to CSV format
   */
  async exportToCSV(startDate: Date, endDate: Date): Promise<string> {
    // Get logs for date range
    const logs = await logService.getLogsByDateRange(startDate, endDate);

    // Create CSV content
    const headers = [
      'Timestamp',
      'Date',
      'Time',
      'Content',
      'Category',
      'Entry Type',
      'Tags',
      'Mood',
    ];

    const rows = logs.map((log) => [
      log.timestamp,
      format(new Date(log.timestamp), 'yyyy-MM-dd'),
      format(new Date(log.timestamp), 'HH:mm:ss'),
      `"${log.content.replace(/"/g, '""')}"`, // Escape quotes
      log.category || '',
      log.entryType,
      log.tags ? log.tags.join(';') : '',
      log.mood || '',
    ]);

    const csvContent = [
      headers.join(','),
      ...rows.map((row) => row.join(',')),
    ].join('\n');

    // Save to file
    const filename = `interval_export_${format(startDate, 'yyyyMMdd')}_${format(endDate, 'yyyyMMdd')}.csv`;
    const filePath = `${this.exportDir}/${filename}`;

    // Ensure export directory exists
    await this.ensureExportDir();

    await RNFS.writeFile(filePath, csvContent, 'utf8');

    // Get file size
    const fileInfo = await RNFS.stat(filePath);

    // Save export record
    await this.saveExportRecord({
      exportType: 'csv',
      dateRangeStart: format(startDate, 'yyyy-MM-dd'),
      dateRangeEnd: format(endDate, 'yyyy-MM-dd'),
      filePath,
      fileSize: fileInfo.size,
      recordCount: logs.length,
    });

    return filePath;
  }

  /**
   * Export logs to JSON format
   */
  async exportToJSON(startDate: Date, endDate: Date): Promise<string> {
    // Get logs for date range
    const logs = await logService.getLogsByDateRange(startDate, endDate);

    // Create JSON content
    const exportData = {
      exportDate: new Date().toISOString(),
      dateRange: {
        start: startDate.toISOString(),
        end: endDate.toISOString(),
      },
      totalLogs: logs.length,
      logs: logs.map((log) => ({
        id: log.id,
        timestamp: log.timestamp,
        date: format(new Date(log.timestamp), 'yyyy-MM-dd'),
        time: format(new Date(log.timestamp), 'HH:mm:ss'),
        content: log.content,
        category: log.category,
        entryType: log.entryType,
        tags: log.tags,
        mood: log.mood,
        createdAt: log.createdAt,
        updatedAt: log.updatedAt,
      })),
    };

    const jsonContent = JSON.stringify(exportData, null, 2);

    // Save to file
    const filename = `interval_export_${format(startDate, 'yyyyMMdd')}_${format(endDate, 'yyyyMMdd')}.json`;
    const filePath = `${this.exportDir}/${filename}`;

    // Ensure export directory exists
    await this.ensureExportDir();

    await RNFS.writeFile(filePath, jsonContent, 'utf8');

    // Get file size
    const fileInfo = await RNFS.stat(filePath);

    // Save export record
    await this.saveExportRecord({
      exportType: 'json',
      dateRangeStart: format(startDate, 'yyyy-MM-dd'),
      dateRangeEnd: format(endDate, 'yyyy-MM-dd'),
      filePath,
      fileSize: fileInfo.size,
      recordCount: logs.length,
    });

    return filePath;
  }

  /**
   * Share exported file
   */
  async shareExport(filePath: string): Promise<void> {
    try {
      await Share.share({
        url: `file://${filePath}`,
        title: 'Interval Export',
      });
    } catch (error) {
      console.error('Failed to share export:', error);
      throw error;
    }
  }

  /**
   * Get export history
   */
  async getExportHistory(): Promise<ExportRecord[]> {
    const results = await databaseService.executeSql(
      `SELECT * FROM exports ORDER BY created_at DESC LIMIT 50`
    );

    return results.map((row) => this.mapRowToExportRecord(row));
  }

  /**
   * Ensure export directory exists
   */
  private async ensureExportDir(): Promise<void> {
    const exists = await RNFS.exists(this.exportDir);
    if (!exists) {
      await RNFS.mkdir(this.exportDir);
    }
  }

  /**
   * Save export record to database
   */
  private async saveExportRecord(data: Omit<ExportRecord, 'id' | 'createdAt'>): Promise<void> {
    const now = Date.now();
    const id = uuidv4();

    await databaseService.executeSql(
      `INSERT INTO exports (
        id, export_type, date_range_start, date_range_end,
        file_path, file_size, record_count, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id,
        data.exportType,
        data.dateRangeStart,
        data.dateRangeEnd,
        data.filePath,
        data.fileSize,
        data.recordCount,
        now,
      ]
    );
  }

  /**
   * Map database row to ExportRecord
   */
  private mapRowToExportRecord(row: any): ExportRecord {
    return {
      id: row.id,
      exportType: row.export_type,
      dateRangeStart: row.date_range_start,
      dateRangeEnd: row.date_range_end,
      filePath: row.file_path,
      fileSize: row.file_size,
      recordCount: row.record_count,
      createdAt: row.created_at,
    };
  }
}

export const exportService = new ExportService();
