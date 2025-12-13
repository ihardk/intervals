/**
 * Database Service - SQLite wrapper with migrations
 */

import SQLite from 'react-native-sqlite-storage';

SQLite.DEBUG(false);
SQLite.enablePromise(true);

export interface SQLStatement {
  sql: string;
  params?: any[];
}

export interface IDatabaseService {
  initialize(): Promise<void>;
  executeSql(sql: string, params?: any[]): Promise<any[]>;
  transaction(statements: SQLStatement[]): Promise<void>;
  close(): Promise<void>;
  getPath(): string;
}

class DatabaseService implements IDatabaseService {
  private db: SQLite.SQLiteDatabase | null = null;
  private readonly dbName = 'interval.db';
  private readonly dbLocation = 'default';

  async initialize(): Promise<void> {
    try {
      this.db = await SQLite.openDatabase({
        name: this.dbName,
        location: this.dbLocation,
      });

      console.log('Database opened successfully');

      // Run migrations
      await this.runMigrations();
    } catch (error) {
      console.error('Failed to initialize database:', error);
      throw error;
    }
  }

  private async runMigrations(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    // Check if migrations table exists
    await this.executeSql(`
      CREATE TABLE IF NOT EXISTS migrations (
        version INTEGER PRIMARY KEY,
        applied_at INTEGER NOT NULL
      )
    `);

    const currentVersion = await this.getCurrentVersion();

    // Migration v1: Initial schema
    if (currentVersion < 1) {
      await this.transaction([
        // Logs table
        {
          sql: `
            CREATE TABLE logs (
              id TEXT PRIMARY KEY,
              timestamp INTEGER NOT NULL,
              content TEXT NOT NULL,
              entry_type TEXT NOT NULL,
              audio_path TEXT,
              transcription_status TEXT DEFAULT 'complete',
              category TEXT,
              tags TEXT,
              mood TEXT,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              is_deleted INTEGER DEFAULT 0,
              metadata TEXT
            )
          `,
        },
        {
          sql: 'CREATE INDEX idx_logs_timestamp ON logs(timestamp DESC)',
        },
        {
          sql: 'CREATE INDEX idx_logs_created_at ON logs(created_at DESC)',
        },
        {
          sql: 'CREATE INDEX idx_logs_category ON logs(category)',
        },
        {
          sql: 'CREATE INDEX idx_logs_entry_type ON logs(entry_type)',
        },
        {
          sql: 'CREATE INDEX idx_logs_is_deleted ON logs(is_deleted)',
        },

        // Intervals table
        {
          sql: `
            CREATE TABLE intervals (
              id TEXT PRIMARY KEY,
              scheduled_time INTEGER NOT NULL,
              actual_time INTEGER,
              response_time INTEGER,
              response_type TEXT,
              log_id TEXT,
              interval_duration INTEGER NOT NULL,
              is_completed INTEGER DEFAULT 0,
              created_at INTEGER NOT NULL,
              FOREIGN KEY (log_id) REFERENCES logs(id)
            )
          `,
        },
        {
          sql: 'CREATE INDEX idx_intervals_scheduled ON intervals(scheduled_time DESC)',
        },
        {
          sql: 'CREATE INDEX idx_intervals_completed ON intervals(is_completed)',
        },
        {
          sql: 'CREATE INDEX idx_intervals_response ON intervals(response_type)',
        },

        // Settings table
        {
          sql: `
            CREATE TABLE settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL,
              type TEXT NOT NULL,
              updated_at INTEGER NOT NULL
            )
          `,
        },

        // Insert default settings
        {
          sql: `INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)`,
          params: ['interval_duration', '900000', 'number', Date.now()],
        },
        {
          sql: `INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)`,
          params: ['notifications_enabled', 'true', 'boolean', Date.now()],
        },
        {
          sql: `INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)`,
          params: ['voice_enabled', 'true', 'boolean', Date.now()],
        },
        {
          sql: `INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)`,
          params: ['theme', 'dark', 'string', Date.now()],
        },
        {
          sql: `INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)`,
          params: ['daily_reminder_time', '20:00', 'string', Date.now()],
        },
        {
          sql: `INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)`,
          params: ['auto_categorize', 'true', 'boolean', Date.now()],
        },
        {
          sql: `INSERT INTO settings (key, value, type, updated_at) VALUES (?, ?, ?, ?)`,
          params: ['onboarding_completed', 'false', 'boolean', Date.now()],
        },

        // Insights table
        {
          sql: `
            CREATE TABLE insights (
              id TEXT PRIMARY KEY,
              insight_type TEXT NOT NULL,
              date TEXT NOT NULL,
              data TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              expires_at INTEGER
            )
          `,
        },
        {
          sql: 'CREATE INDEX idx_insights_type_date ON insights(insight_type, date DESC)',
        },
        {
          sql: 'CREATE INDEX idx_insights_expires ON insights(expires_at)',
        },

        // Categories table
        {
          sql: `
            CREATE TABLE categories (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL UNIQUE,
              color TEXT,
              keywords TEXT NOT NULL,
              parent_category TEXT,
              is_system INTEGER DEFAULT 0,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          `,
        },
        {
          sql: 'CREATE INDEX idx_categories_name ON categories(name)',
        },

        // Streaks table
        {
          sql: `
            CREATE TABLE streaks (
              id TEXT PRIMARY KEY,
              streak_type TEXT NOT NULL,
              start_date TEXT NOT NULL,
              end_date TEXT,
              current_count INTEGER NOT NULL,
              best_count INTEGER NOT NULL,
              is_active INTEGER DEFAULT 1,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          `,
        },
        {
          sql: 'CREATE INDEX idx_streaks_type ON streaks(streak_type)',
        },
        {
          sql: 'CREATE INDEX idx_streaks_active ON streaks(is_active)',
        },

        // Exports table
        {
          sql: `
            CREATE TABLE exports (
              id TEXT PRIMARY KEY,
              export_type TEXT NOT NULL,
              date_range_start TEXT NOT NULL,
              date_range_end TEXT NOT NULL,
              file_path TEXT NOT NULL,
              file_size INTEGER,
              record_count INTEGER,
              created_at INTEGER NOT NULL
            )
          `,
        },
        {
          sql: 'CREATE INDEX idx_exports_created ON exports(created_at DESC)',
        },

        // Record migration
        {
          sql: 'INSERT INTO migrations (version, applied_at) VALUES (?, ?)',
          params: [1, Date.now()],
        },
      ]);

      console.log('Migration v1 applied successfully');
    }
  }

  private async getCurrentVersion(): Promise<number> {
    try {
      const results = await this.executeSql(
        'SELECT MAX(version) as version FROM migrations'
      );
      return results[0]?.version || 0;
    } catch (error) {
      return 0;
    }
  }

  async executeSql(sql: string, params: any[] = []): Promise<any[]> {
    if (!this.db) throw new Error('Database not initialized');

    try {
      const [results] = await this.db.executeSql(sql, params);
      const rows: any[] = [];

      for (let i = 0; i < results.rows.length; i++) {
        rows.push(results.rows.item(i));
      }

      return rows;
    } catch (error) {
      console.error('SQL Error:', error, 'SQL:', sql, 'Params:', params);
      throw error;
    }
  }

  async transaction(statements: SQLStatement[]): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    return new Promise((resolve, reject) => {
      this.db!.transaction(
        (tx) => {
          statements.forEach(({ sql, params = [] }) => {
            tx.executeSql(sql, params);
          });
        },
        (error) => {
          console.error('Transaction error:', error);
          reject(error);
        },
        () => {
          resolve();
        }
      );
    });
  }

  async close(): Promise<void> {
    if (this.db) {
      await this.db.close();
      this.db = null;
      console.log('Database closed');
    }
  }

  getPath(): string {
    return `${this.dbLocation}/${this.dbName}`;
  }
}

// Singleton instance
export const databaseService = new DatabaseService();
