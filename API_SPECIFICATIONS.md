# API Specifications

## Overview

This document defines the internal service APIs and interfaces for the Interval app. Since this is a local-first application, these are TypeScript interfaces for services, not REST endpoints. Future cloud sync features will add REST APIs.

---

## Core Type Definitions

### Models

```typescript
// src/models/Log.ts

export type EntryType = 'text' | 'voice' | 'manual';
export type TranscriptionStatus = 'pending' | 'complete' | 'failed';

export interface Log {
    id: string;                          // UUID v4
    timestamp: number;                   // Unix timestamp (ms)
    content: string;                     // Log text content
    entryType: EntryType;               // How it was created
    audioPath?: string;                  // Path to audio file
    transcriptionStatus: TranscriptionStatus;
    category?: string;                   // Auto or manual category
    tags?: string[];                     // Flexible tags
    mood?: string;                       // Optional mood
    createdAt: number;                   // Creation timestamp
    updatedAt: number;                   // Last update timestamp
    isDeleted: boolean;                  // Soft delete flag
    metadata?: Record<string, any>;      // Extensible field
}

export interface CreateLogInput {
    content: string;
    entryType: EntryType;
    audioPath?: string;
    timestamp?: number;                  // Defaults to now
    category?: string;
    tags?: string[];
    mood?: string;
}

export interface UpdateLogInput {
    id: string;
    content?: string;
    category?: string;
    tags?: string[];
    mood?: string;
}
```

```typescript
// src/models/Interval.ts

export type ResponseType = 'logged' | 'skipped' | 'ignored';

export interface Interval {
    id: string;
    scheduledTime: number;               // When should fire
    actualTime?: number;                 // When actually fired
    responseTime?: number;               // User response time
    responseType?: ResponseType;
    logId?: string;                      // FK to Log
    intervalDuration: number;            // 900000 or 1800000 ms
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
```

```typescript
// src/models/Settings.ts

export type SettingType = 'string' | 'number' | 'boolean' | 'json';

export interface Setting {
    key: string;
    value: string;                       // Stored as string
    type: SettingType;
    updatedAt: number;
}

export interface AppSettings {
    intervalDuration: number;            // 900000 or 1800000
    notificationsEnabled: boolean;
    voiceEnabled: boolean;
    theme: 'dark' | 'light';
    dailyReminderTime: string;           // HH:MM
    autoCategorize: boolean;
    onboardingCompleted: boolean;
}
```

```typescript
// src/models/Insight.ts

export type InsightType = 'daily' | 'weekly' | 'monthly' | 'pattern';

export interface Insight {
    id: string;
    insightType: InsightType;
    date: string;                        // ISO date YYYY-MM-DD
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
```

```typescript
// src/models/Category.ts

export interface Category {
    id: string;
    name: string;
    color?: string;                      // Hex color
    keywords: string[];
    parentCategory?: string;
    isSystem: boolean;
    createdAt: number;
    updatedAt: number;
}
```

---

## Service Interfaces

### 1. Database Service

```typescript
// src/services/database/DatabaseService.ts

export interface IDatabaseService {
    /**
     * Initialize the database and run migrations
     */
    initialize(): Promise<void>;

    /**
     * Execute a raw SQL query
     */
    executeSql(sql: string, params?: any[]): Promise<any[]>;

    /**
     * Execute multiple SQL statements in a transaction
     */
    transaction(statements: SQLStatement[]): Promise<void>;

    /**
     * Close database connection
     */
    close(): Promise<void>;

    /**
     * Get database file path
     */
    getPath(): string;
}

export interface SQLStatement {
    sql: string;
    params?: any[];
}
```

### 2. Log Service

```typescript
// src/services/logs/LogService.ts

export interface ILogService {
    /**
     * Create a new log entry
     */
    createLog(input: CreateLogInput): Promise<Log>;

    /**
     * Get a log by ID
     */
    getLogById(id: string): Promise<Log | null>;

    /**
     * Get logs for a date range
     */
    getLogsByDateRange(startDate: Date, endDate: Date): Promise<Log[]>;

    /**
     * Get today's logs
     */
    getTodayLogs(): Promise<Log[]>;

    /**
     * Update a log
     */
    updateLog(input: UpdateLogInput): Promise<Log>;

    /**
     * Soft delete a log
     */
    deleteLog(id: string): Promise<void>;

    /**
     * Permanently delete old soft-deleted logs
     */
    purgeDeletedLogs(olderThanDays: number): Promise<number>;

    /**
     * Search logs by content
     */
    searchLogs(query: string, limit?: number): Promise<Log[]>;

    /**
     * Get logs by category
     */
    getLogsByCategory(category: string): Promise<Log[]>;

    /**
     * Get all logs (paginated)
     */
    getAllLogs(offset: number, limit: number): Promise<Log[]>;
}
```

### 3. Interval Service

```typescript
// src/services/intervals/IntervalService.ts

export interface IIntervalService {
    /**
     * Create a new interval
     */
    createInterval(input: CreateIntervalInput): Promise<Interval>;

    /**
     * Mark interval as completed
     */
    completeInterval(input: CompleteIntervalInput): Promise<Interval>;

    /**
     * Get upcoming interval
     */
    getNextInterval(): Promise<Interval | null>;

    /**
     * Get intervals for date range
     */
    getIntervalsByDateRange(startDate: Date, endDate: Date): Promise<Interval[]>;

    /**
     * Calculate completion rate for a date
     */
    getCompletionRate(date: Date): Promise<number>;

    /**
     * Get recent skipped intervals count
     */
    getRecentSkippedCount(hours: number): Promise<number>;
}
```

### 4. Notification Service

```typescript
// src/services/notification/NotificationService.ts

export interface INotificationService {
    /**
     * Request notification permissions
     */
    requestPermissions(): Promise<boolean>;

    /**
     * Check if permissions granted
     */
    hasPermissions(): Promise<boolean>;

    /**
     * Schedule next interval notification
     */
    scheduleIntervalNotification(intervalMs: number): Promise<string>;

    /**
     * Cancel a scheduled notification
     */
    cancelNotification(notificationId: string): Promise<void>;

    /**
     * Cancel all notifications
     */
    cancelAllNotifications(): Promise<void>;

    /**
     * Handle notification response
     */
    handleNotificationResponse(response: NotificationResponse): Promise<void>;

    /**
     * Show immediate notification (testing/debug)
     */
    showNotification(title: string, body: string): Promise<void>;
}

export interface NotificationResponse {
    notificationId: string;
    actionId?: string;                   // 'text' | 'voice' | 'skip'
    timestamp: number;
}
```

### 5. Voice Service

```typescript
// src/services/voice/VoiceService.ts

export interface IVoiceService {
    /**
     * Request microphone permissions
     */
    requestPermissions(): Promise<boolean>;

    /**
     * Check if permissions granted
     */
    hasPermissions(): Promise<boolean>;

    /**
     * Start recording
     */
    startRecording(): Promise<void>;

    /**
     * Stop recording and return file path
     */
    stopRecording(): Promise<string>;

    /**
     * Cancel current recording
     */
    cancelRecording(): Promise<void>;

    /**
     * Transcribe audio file
     */
    transcribeAudio(audioPath: string): Promise<TranscriptionResult>;

    /**
     * Play audio file
     */
    playAudio(audioPath: string): Promise<void>;

    /**
     * Stop audio playback
     */
    stopPlayback(): Promise<void>;

    /**
     * Get recording status
     */
    isRecording(): boolean;
}

export interface TranscriptionResult {
    text: string;
    confidence?: number;
    error?: string;
}
```

### 6. Settings Service

```typescript
// src/services/settings/SettingsService.ts

export interface ISettingsService {
    /**
     * Get all settings as AppSettings object
     */
    getSettings(): Promise<AppSettings>;

    /**
     * Get a single setting by key
     */
    getSetting<T>(key: keyof AppSettings): Promise<T>;

    /**
     * Update a setting
     */
    setSetting<T>(key: keyof AppSettings, value: T): Promise<void>;

    /**
     * Update multiple settings
     */
    updateSettings(settings: Partial<AppSettings>): Promise<void>;

    /**
     * Reset to default settings
     */
    resetSettings(): Promise<void>;

    /**
     * Get interval duration in milliseconds
     */
    getIntervalDuration(): Promise<number>;

    /**
     * Set interval duration
     */
    setIntervalDuration(durationMs: number): Promise<void>;
}
```

### 7. Insight Service

```typescript
// src/services/insights/InsightService.ts

export interface IInsightService {
    /**
     * Generate daily insight for a date
     */
    generateDailyInsight(date: Date): Promise<Insight>;

    /**
     * Generate weekly insight
     */
    generateWeeklyInsight(weekStartDate: Date): Promise<Insight>;

    /**
     * Generate monthly insight
     */
    generateMonthlyInsight(month: number, year: number): Promise<Insight>;

    /**
     * Get cached insight or generate new
     */
    getInsight(type: InsightType, date: string): Promise<Insight>;

    /**
     * Detect patterns in logs
     */
    detectPatterns(logs: Log[]): Promise<PatternDetectionResult>;

    /**
     * Calculate productivity score
     */
    calculateProductivityScore(logs: Log[]): Promise<number>;

    /**
     * Get top activities
     */
    getTopActivities(logs: Log[], limit: number): Promise<ActivityCount[]>;
}

export interface PatternDetectionResult {
    peakHours: number[];
    distractionPeriods: number[];
    recurringActivities: string[];
    timeDistribution: Record<string, number>;
}
```

### 8. Category Service

```typescript
// src/services/categories/CategoryService.ts

export interface ICategoryService {
    /**
     * Get all categories
     */
    getAllCategories(): Promise<Category[]>;

    /**
     * Get category by ID
     */
    getCategoryById(id: string): Promise<Category | null>;

    /**
     * Create a new category
     */
    createCategory(name: string, keywords: string[], color?: string): Promise<Category>;

    /**
     * Update category
     */
    updateCategory(id: string, updates: Partial<Category>): Promise<Category>;

    /**
     * Delete category
     */
    deleteCategory(id: string): Promise<void>;

    /**
     * Auto-categorize a log based on content
     */
    categorizeLog(content: string): Promise<string | null>;

    /**
     * Initialize default categories
     */
    initializeDefaultCategories(): Promise<void>;
}
```

### 9. Streak Service

```typescript
// src/services/streaks/StreakService.ts

export interface IStreakService {
    /**
     * Get current active streak
     */
    getCurrentStreak(): Promise<number>;

    /**
     * Get best streak ever
     */
    getBestStreak(): Promise<number>;

    /**
     * Update streak based on today's activity
     */
    updateStreak(): Promise<void>;

    /**
     * Check if streak is maintained
     */
    isStreakActive(): Promise<boolean>;
}
```

### 10. Export Service

```typescript
// src/services/export/ExportService.ts

export interface IExportService {
    /**
     * Export logs to CSV
     */
    exportToCSV(startDate: Date, endDate: Date): Promise<string>;

    /**
     * Export logs to JSON
     */
    exportToJSON(startDate: Date, endDate: Date): Promise<string>;

    /**
     * Share exported file
     */
    shareExport(filePath: string): Promise<void>;

    /**
     * Get all exports
     */
    getExportHistory(): Promise<ExportRecord[]>;
}

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
```

---

## State Management (Zustand Stores)

### Logs Store

```typescript
// src/store/logsStore.ts

export interface LogsStore {
    // State
    logs: Log[];
    currentLog: Log | null;
    isLoading: boolean;
    error: string | null;

    // Actions
    fetchTodayLogs: () => Promise<void>;
    fetchLogsByDateRange: (start: Date, end: Date) => Promise<void>;
    createLog: (input: CreateLogInput) => Promise<Log>;
    updateLog: (input: UpdateLogInput) => Promise<Log>;
    deleteLog: (id: string) => Promise<void>;
    setCurrentLog: (log: Log | null) => void;
    clearError: () => void;
}
```

### Settings Store

```typescript
// src/store/settingsStore.ts

export interface SettingsStore {
    // State
    settings: AppSettings | null;
    isLoading: boolean;
    error: string | null;

    // Actions
    loadSettings: () => Promise<void>;
    updateSetting: <K extends keyof AppSettings>(
        key: K,
        value: AppSettings[K]
    ) => Promise<void>;
    updateSettings: (updates: Partial<AppSettings>) => Promise<void>;
    resetSettings: () => Promise<void>;
}
```

### Insights Store

```typescript
// src/store/insightsStore.ts

export interface InsightsStore {
    // State
    dailyInsight: Insight | null;
    weeklyInsight: Insight | null;
    monthlyInsight: Insight | null;
    isLoading: boolean;
    error: string | null;

    // Actions
    fetchDailyInsight: (date?: Date) => Promise<void>;
    fetchWeeklyInsight: (weekStart?: Date) => Promise<void>;
    fetchMonthlyInsight: (month: number, year: number) => Promise<void>;
    clearInsights: () => void;
}
```

---

## Component Props Interfaces

### Logging Screen

```typescript
export interface LoggingScreenProps {
    navigation: NavigationProp<any>;
    route: RouteProp<any>;
    preselectedMode?: 'text' | 'voice';  // From notification
}
```

### Text Input Component

```typescript
export interface TextInputProps {
    value: string;
    onChangeText: (text: string) => void;
    onSubmit: () => void;
    placeholder?: string;
    autoFocus?: boolean;
    maxLength?: number;
}
```

### Voice Recorder Component

```typescript
export interface VoiceRecorderProps {
    onRecordingComplete: (audioPath: string, transcription: string) => void;
    onCancel: () => void;
}
```

### Insight Card Component

```typescript
export interface InsightCardProps {
    title: string;
    value: string | number;
    subtitle?: string;
    icon?: string;
    color?: string;
}
```

### Log List Item Component

```typescript
export interface LogListItemProps {
    log: Log;
    onPress?: (log: Log) => void;
    onDelete?: (id: string) => void;
    showDate?: boolean;
}
```

---

## Event Handlers

### Notification Event Types

```typescript
export enum NotificationEvent {
    RECEIVED = 'notification_received',
    OPENED = 'notification_opened',
    ACTION = 'notification_action',
}

export interface NotificationEventData {
    notificationId: string;
    action?: 'text' | 'voice' | 'skip';
    timestamp: number;
}
```

### Voice Recording Events

```typescript
export enum VoiceRecordingEvent {
    START = 'recording_start',
    STOP = 'recording_stop',
    ERROR = 'recording_error',
    TRANSCRIPTION_COMPLETE = 'transcription_complete',
}
```

---

## Error Handling

### Custom Error Types

```typescript
export class DatabaseError extends Error {
    constructor(message: string, public code?: string) {
        super(message);
        this.name = 'DatabaseError';
    }
}

export class NotificationError extends Error {
    constructor(message: string, public code?: string) {
        super(message);
        this.name = 'NotificationError';
    }
}

export class VoiceError extends Error {
    constructor(message: string, public code?: string) {
        super(message);
        this.name = 'VoiceError';
    }
}

export class PermissionError extends Error {
    constructor(message: string, public permissionType: string) {
        super(message);
        this.name = 'PermissionError';
    }
}
```

### Error Response Format

```typescript
export interface ErrorResponse {
    success: false;
    error: {
        message: string;
        code?: string;
        details?: any;
    };
}

export interface SuccessResponse<T> {
    success: true;
    data: T;
}

export type ServiceResponse<T> = SuccessResponse<T> | ErrorResponse;
```

---

## Utility Types

```typescript
// Pagination
export interface PaginationParams {
    offset: number;
    limit: number;
}

export interface PaginatedResult<T> {
    items: T[];
    total: number;
    offset: number;
    limit: number;
    hasMore: boolean;
}

// Date Range
export interface DateRange {
    startDate: Date;
    endDate: Date;
}

// Time Slot
export interface TimeSlot {
    hour: number;
    count: number;
}
```

---

## Future: Cloud Sync API (Phase 4)

When cloud sync is implemented, REST API:

### Endpoints

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/sync/logs              - Sync logs
GET    /api/sync/logs/:since       - Get logs since timestamp
POST   /api/sync/settings          - Sync settings
GET    /api/sync/conflicts         - Get sync conflicts
POST   /api/sync/resolve           - Resolve conflicts
```

### Sync Request

```typescript
export interface SyncRequest {
    deviceId: string;
    lastSyncTimestamp: number;
    logs: Log[];
    settings: AppSettings;
}

export interface SyncResponse {
    success: boolean;
    serverLogs: Log[];
    conflicts: SyncConflict[];
    lastSyncTimestamp: number;
}

export interface SyncConflict {
    logId: string;
    localLog: Log;
    serverLog: Log;
    conflictType: 'content' | 'category' | 'deleted';
}
```

---

## Testing Interfaces

```typescript
export interface MockDatabaseService extends IDatabaseService {
    reset(): void;
    seed(data: any): void;
}

export interface TestLog extends Partial<Log> {
    id: string;
    content: string;
}
```

---

## Performance Monitoring

```typescript
export interface PerformanceMetrics {
    appLaunchTime: number;
    databaseQueryTime: number;
    notificationDeliveryRate: number;
    transcriptionTime: number;
    insightGenerationTime: number;
}

export interface IPerformanceMonitor {
    startTracking(metricName: string): void;
    endTracking(metricName: string): number;
    getMetrics(): PerformanceMetrics;
}
```

---

## Notes

- All timestamps are in milliseconds (Unix epoch)
- All dates stored as ISO 8601 strings (YYYY-MM-DD)
- UUIDs generated with uuid v4
- All async operations return Promises
- Error handling uses try/catch with custom error types
- Services use dependency injection for testability

**Last Updated:** 2025-12-12
