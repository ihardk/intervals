import 'package:intl/intl.dart';

/// Date and time utility functions
class DateHelpers {
  /// Get start of day timestamp in milliseconds
  static int startOfDay(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    return start.millisecondsSinceEpoch;
  }

  /// Get end of day timestamp in milliseconds
  static int endOfDay(DateTime date) {
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return end.millisecondsSinceEpoch;
  }

  /// Get start of today timestamp
  static int startOfToday() {
    return startOfDay(DateTime.now());
  }

  /// Get end of today timestamp
  static int endOfToday() {
    return endOfDay(DateTime.now());
  }

  /// Check if timestamp is today
  static bool isToday(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if timestamp is yesterday
  static bool isYesterday(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Format timestamp to readable date string
  static String formatDate(int timestamp, [String pattern = 'MMM d, yyyy']) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(pattern).format(date);
  }

  /// Format timestamp to readable time string
  static String formatTime(int timestamp, [String pattern = 'h:mm a']) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(pattern).format(date);
  }

  /// Format timestamp to readable date and time string
  static String formatDateTime(int timestamp, [String pattern = 'MMM d, yyyy h:mm a']) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(pattern).format(date);
  }

  /// Get relative time string (e.g., "2 hours ago", "just now")
  static String getRelativeTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Convert DateTime to ISO 8601 date string (YYYY-MM-DD)
  static String toIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parse ISO 8601 date string to DateTime
  static DateTime fromIsoDate(String isoDate) {
    return DateTime.parse(isoDate);
  }

  /// Get date range for current week
  static ({int start, int end}) getCurrentWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return (
      start: startOfDay(startOfWeek),
      end: endOfDay(endOfWeek),
    );
  }

  /// Get date range for current month
  static ({int start, int end}) getCurrentMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return (
      start: startOfDay(startOfMonth),
      end: endOfDay(endOfMonth),
    );
  }

  /// Get hour of day from timestamp (0-23)
  static int getHour(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date.hour;
  }

  /// Get day of week from timestamp (1-7, Monday-Sunday)
  static int getDayOfWeek(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date.weekday;
  }

  /// Get name of day from timestamp
  static String getDayName(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('EEEE').format(date);
  }

  /// Get short name of day from timestamp
  static String getShortDayName(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('EEE').format(date);
  }

  /// Private constructor to prevent instantiation
  DateHelpers._();
}
