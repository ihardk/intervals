/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Interval';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Minimalist Awareness & Productivity Logger';

  // Database
  static const String databaseName = 'interval.db';
  static const int databaseVersion = 1;

  // Settings Keys
  static const String keyIntervalDuration = 'interval_duration';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyVoiceEnabled = 'voice_enabled';
  static const String keyTheme = 'theme';
  static const String keyDailyReminderTime = 'daily_reminder_time';
  static const String keyAutoCategorize = 'auto_categorize';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // Notification
  static const String notificationChannelId = 'interval_channel';
  static const String notificationChannelName = 'Interval Notifications';
  static const String notificationChannelDescription = 'Notifications for interval logging';
  static const int notificationId = 0;

  // Notification Actions
  static const String notificationActionText = 'text';
  static const String notificationActionVoice = 'voice';
  static const String notificationActionSkip = 'skip';

  // Limits
  static const int maxLogContentLength = 500;
  static const int maxCategoryNameLength = 50;
  static const int maxExportRecords = 10000;

  // Data Retention
  static const int deletedLogsPurgeDays = 30;
  static const int intervalsRetentionDays = 90;
  static const int insightsCacheDays = 365;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration databaseTimeout = Duration(seconds: 10);

  // Entry Types
  static const String entryTypeText = 'text';
  static const String entryTypeVoice = 'voice';
  static const String entryTypeManual = 'manual';

  // Transcription Status
  static const String transcriptionPending = 'pending';
  static const String transcriptionComplete = 'complete';
  static const String transcriptionFailed = 'failed';

  // Response Types
  static const String responseLogged = 'logged';
  static const String responseSkipped = 'skipped';
  static const String responseIgnored = 'ignored';

  // Insight Types
  static const String insightTypeDaily = 'daily';
  static const String insightTypeWeekly = 'weekly';
  static const String insightTypeMonthly = 'monthly';
  static const String insightTypePattern = 'pattern';

  // Export Types
  static const String exportTypeCsv = 'csv';
  static const String exportTypeJson = 'json';

  // Streak Types
  static const String streakTypeDailyLogs = 'daily_logs';
  static const String streakTypeConsistentIntervals = 'consistent_intervals';
  static const String streakTypeNoSkip = 'no_skip';

  // Private constructor to prevent instantiation
  AppConstants._();
}
