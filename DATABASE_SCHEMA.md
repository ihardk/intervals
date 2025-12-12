# Database Schema Design

## Overview

Interval uses SQLite for local data persistence. The schema is designed for simplicity, performance, and privacy. All data remains on-device unless the user explicitly enables cloud sync.

## Schema Version: 1.0

## Tables

### 1. logs

Primary table storing all user activity logs.

```sql
CREATE TABLE logs (
    id TEXT PRIMARY KEY,                    -- UUID v4
    timestamp INTEGER NOT NULL,             -- Unix timestamp (ms) when logged
    content TEXT NOT NULL,                  -- The actual log text
    entry_type TEXT NOT NULL,               -- 'text' | 'voice' | 'manual'
    audio_path TEXT,                        -- Path to audio file (if voice)
    transcription_status TEXT DEFAULT 'complete', -- 'pending' | 'complete' | 'failed'
    category TEXT,                          -- Auto-detected or manual category
    tags TEXT,                              -- JSON array of tags
    mood TEXT,                              -- Optional mood indicator
    created_at INTEGER NOT NULL,            -- Unix timestamp (ms)
    updated_at INTEGER NOT NULL,            -- Unix timestamp (ms)
    is_deleted INTEGER DEFAULT 0,           -- Soft delete flag
    metadata TEXT                           -- JSON for extensibility
);

CREATE INDEX idx_logs_timestamp ON logs(timestamp DESC);
CREATE INDEX idx_logs_created_at ON logs(created_at DESC);
CREATE INDEX idx_logs_category ON logs(category);
CREATE INDEX idx_logs_entry_type ON logs(entry_type);
CREATE INDEX idx_logs_is_deleted ON logs(is_deleted);
```

**Field Descriptions:**

- `id`: Unique identifier for each log entry
- `timestamp`: When the activity actually happened (user can adjust)
- `content`: The log text (transcription if voice)
- `entry_type`: How the log was created
- `audio_path`: Relative path to stored audio file
- `transcription_status`: Voice-to-text processing status
- `category`: Detected category (work, break, meeting, etc.)
- `tags`: Flexible tagging system stored as JSON
- `mood`: Optional emotional state
- `created_at`: System creation time
- `updated_at`: Last modification time
- `is_deleted`: Soft delete for undo functionality
- `metadata`: Extensible JSON field for future features

**Example Row:**
```json
{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": 1704892800000,
    "content": "Working on database schema design",
    "entry_type": "text",
    "audio_path": null,
    "transcription_status": "complete",
    "category": "work",
    "tags": "[\"development\", \"planning\"]",
    "mood": null,
    "created_at": 1704892800000,
    "updated_at": 1704892800000,
    "is_deleted": 0,
    "metadata": "{}"
}
```

---

### 2. intervals

Tracks notification intervals and user responses.

```sql
CREATE TABLE intervals (
    id TEXT PRIMARY KEY,                    -- UUID v4
    scheduled_time INTEGER NOT NULL,        -- When notification should fire
    actual_time INTEGER,                    -- When notification actually fired
    response_time INTEGER,                  -- When user responded
    response_type TEXT,                     -- 'logged' | 'skipped' | 'ignored'
    log_id TEXT,                           -- FK to logs.id if logged
    interval_duration INTEGER NOT NULL,     -- 900000 (15min) or 1800000 (30min)
    is_completed INTEGER DEFAULT 0,        -- Whether interval was handled
    created_at INTEGER NOT NULL,
    FOREIGN KEY (log_id) REFERENCES logs(id)
);

CREATE INDEX idx_intervals_scheduled ON intervals(scheduled_time DESC);
CREATE INDEX idx_intervals_completed ON intervals(is_completed);
CREATE INDEX idx_intervals_response ON intervals(response_type);
```

**Field Descriptions:**

- `scheduled_time`: Target notification time
- `actual_time`: When notification was actually sent
- `response_time`: User interaction timestamp
- `response_type`: User's action
- `log_id`: Links to created log if user logged
- `interval_duration`: User's chosen interval (ms)
- `is_completed`: Processing flag

**Purpose:** Track notification delivery reliability and user engagement patterns.

---

### 3. settings

User preferences and app configuration.

```sql
CREATE TABLE settings (
    key TEXT PRIMARY KEY,                   -- Setting identifier
    value TEXT NOT NULL,                    -- Setting value (JSON)
    type TEXT NOT NULL,                     -- 'string' | 'number' | 'boolean' | 'json'
    updated_at INTEGER NOT NULL             -- Last modification time
);

-- Insert default settings
INSERT INTO settings (key, value, type, updated_at) VALUES
    ('interval_duration', '900000', 'number', strftime('%s', 'now') * 1000),
    ('notifications_enabled', 'true', 'boolean', strftime('%s', 'now') * 1000),
    ('voice_enabled', 'true', 'boolean', strftime('%s', 'now') * 1000),
    ('theme', 'dark', 'string', strftime('%s', 'now') * 1000),
    ('daily_reminder_time', '20:00', 'string', strftime('%s', 'now') * 1000),
    ('auto_categorize', 'true', 'boolean', strftime('%s', 'now') * 1000),
    ('onboarding_completed', 'false', 'boolean', strftime('%s', 'now') * 1000);
```

**Common Settings:**

| Key | Value | Type | Description |
|-----|-------|------|-------------|
| interval_duration | 900000 or 1800000 | number | Notification interval in ms |
| notifications_enabled | true/false | boolean | Master notification toggle |
| voice_enabled | true/false | boolean | Voice input feature |
| theme | dark/light | string | UI theme (future) |
| daily_reminder_time | HH:MM | string | Evening reflection time |
| auto_categorize | true/false | boolean | Auto-detect categories |
| onboarding_completed | true/false | boolean | First-run flag |

---

### 4. insights

Pre-computed insights and analytics.

```sql
CREATE TABLE insights (
    id TEXT PRIMARY KEY,
    insight_type TEXT NOT NULL,             -- 'daily' | 'weekly' | 'monthly' | 'pattern'
    date TEXT NOT NULL,                     -- ISO date (YYYY-MM-DD)
    data TEXT NOT NULL,                     -- JSON insight data
    created_at INTEGER NOT NULL,
    expires_at INTEGER                      -- Optional cache expiration
);

CREATE INDEX idx_insights_type_date ON insights(insight_type, date DESC);
CREATE INDEX idx_insights_expires ON insights(expires_at);
```

**Field Descriptions:**

- `insight_type`: Category of insight
- `date`: Reference date for the insight
- `data`: JSON containing insight details
- `expires_at`: Cache invalidation timestamp

**Example Daily Insight Data:**
```json
{
    "total_logs": 32,
    "skipped_intervals": 4,
    "completion_rate": 0.89,
    "streak_days": 7,
    "top_activities": [
        {"activity": "coding", "count": 12},
        {"activity": "meetings", "count": 8},
        {"activity": "break", "count": 5}
    ],
    "productivity_score": 0.85,
    "peak_hours": [9, 10, 14, 15],
    "distraction_periods": [13, 16]
}
```

---

### 5. categories

Category definitions for auto-categorization.

```sql
CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    color TEXT,                             -- Hex color for UI
    keywords TEXT NOT NULL,                 -- JSON array of keywords
    parent_category TEXT,                   -- For hierarchical categories
    is_system INTEGER DEFAULT 0,            -- System vs user-created
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX idx_categories_name ON categories(name);

-- Default categories
INSERT INTO categories (id, name, color, keywords, is_system, created_at, updated_at) VALUES
    ('cat_work', 'Work', '#3B82F6', '["coding", "meeting", "email", "project", "client"]', 1, strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000),
    ('cat_break', 'Break', '#10B981', '["break", "coffee", "lunch", "rest", "walk"]', 1, strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000),
    ('cat_learning', 'Learning', '#8B5CF6', '["reading", "course", "tutorial", "studying", "research"]', 1, strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000),
    ('cat_social', 'Social', '#F59E0B', '["chat", "call", "social media", "messaging"]', 1, strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000),
    ('cat_distraction', 'Distraction', '#EF4444', '["browsing", "youtube", "scrolling", "distracted"]', 1, strftime('%s', 'now') * 1000, strftime('%s', 'now') * 1000);
```

---

### 6. streaks

Track user consistency and streaks.

```sql
CREATE TABLE streaks (
    id TEXT PRIMARY KEY,
    streak_type TEXT NOT NULL,              -- 'daily_logs' | 'consistent_intervals' | 'no_skip'
    start_date TEXT NOT NULL,               -- ISO date
    end_date TEXT,                          -- ISO date (null if ongoing)
    current_count INTEGER NOT NULL,
    best_count INTEGER NOT NULL,
    is_active INTEGER DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX idx_streaks_type ON streaks(streak_type);
CREATE INDEX idx_streaks_active ON streaks(is_active);
```

---

### 7. exports

Track data exports for user reference.

```sql
CREATE TABLE exports (
    id TEXT PRIMARY KEY,
    export_type TEXT NOT NULL,              -- 'csv' | 'json' | 'pdf'
    date_range_start TEXT NOT NULL,         -- ISO date
    date_range_end TEXT NOT NULL,           -- ISO date
    file_path TEXT NOT NULL,
    file_size INTEGER,                      -- Bytes
    record_count INTEGER,
    created_at INTEGER NOT NULL
);

CREATE INDEX idx_exports_created ON exports(created_at DESC);
```

---

## Relationships

```
logs (1) ←──── (0..1) intervals
logs (1) ←──── (0..1) categories
insights (1) ←──── (*) logs (computed)
streaks (1) ←──── (*) logs (computed)
```

## Data Retention Policy

- **Logs**: Indefinite (user-controlled deletion)
- **Intervals**: 90 days rolling window
- **Insights**: 1 year (can be regenerated)
- **Exports**: Until manually deleted
- **Deleted logs**: Purged after 30 days

## Database Migrations

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01 | Initial schema |

### Migration Strategy

```javascript
const migrations = [
    {
        version: 1,
        up: `
            CREATE TABLE logs (...);
            CREATE TABLE intervals (...);
            -- ... all initial tables
        `
    },
    // Future migrations
    {
        version: 2,
        up: `
            ALTER TABLE logs ADD COLUMN location TEXT;
        `
    }
];
```

## Query Patterns

### Common Queries

**1. Get today's logs:**
```sql
SELECT * FROM logs
WHERE date(timestamp/1000, 'unixepoch', 'localtime') = date('now', 'localtime')
  AND is_deleted = 0
ORDER BY timestamp DESC;
```

**2. Calculate completion rate for today:**
```sql
SELECT
    COUNT(CASE WHEN response_type = 'logged' THEN 1 END) * 1.0 / COUNT(*) as rate
FROM intervals
WHERE date(scheduled_time/1000, 'unixepoch', 'localtime') = date('now', 'localtime');
```

**3. Top activities in last 7 days:**
```sql
SELECT category, COUNT(*) as count
FROM logs
WHERE timestamp >= strftime('%s', 'now', '-7 days') * 1000
  AND is_deleted = 0
  AND category IS NOT NULL
GROUP BY category
ORDER BY count DESC
LIMIT 10;
```

**4. Current active streak:**
```sql
SELECT * FROM streaks
WHERE streak_type = 'daily_logs'
  AND is_active = 1
ORDER BY created_at DESC
LIMIT 1;
```

**5. Logs by hour of day:**
```sql
SELECT
    strftime('%H', timestamp/1000, 'unixepoch', 'localtime') as hour,
    COUNT(*) as count
FROM logs
WHERE is_deleted = 0
GROUP BY hour
ORDER BY hour;
```

## Backup Strategy

### Local Backups
- Daily automatic backup to app documents folder
- User-initiated manual backups
- Export to user-accessible location

### Cloud Backup (Optional)
- Encrypted backup to iCloud/Google Drive
- Incremental sync
- User-controlled

## Performance Considerations

### Indexing Strategy
- Primary indexes on timestamp and created_at
- Composite index on (insight_type, date)
- Covering indexes for common queries

### Optimization Techniques
- VACUUM on monthly schedule
- ANALYZE statistics updates
- Prepared statements for frequent queries
- Batch inserts for bulk operations

### Size Estimates

Assuming average user with 30 logs/day:

| Table | Rows/Day | Avg Row Size | Monthly Size |
|-------|----------|--------------|--------------|
| logs | 30 | 500 bytes | ~450 KB |
| intervals | 48 | 200 bytes | ~288 KB |
| insights | 3 | 2 KB | ~180 KB |
| Total | - | - | ~1 MB/month |

**Annual storage**: ~12 MB (very manageable)

## Privacy & Security

### Encryption
- Database file encrypted with AES-256
- Encryption key stored in device Keychain/KeyStore
- Audio files encrypted separately

### Data Minimization
- No personally identifiable information required
- No location tracking
- No external identifiers

### User Control
- Easy data export
- Complete data deletion
- No telemetry without consent
