/// Interval duration constants
/// Matches the React Native implementation
class IntervalConstants {
  // Interval durations in milliseconds
  static const int fifteenMinutes = 900000;  // 15 * 60 * 1000
  static const int thirtyMinutes = 1800000;  // 30 * 60 * 1000

  // Default interval
  static const int defaultInterval = fifteenMinutes;

  // Display labels
  static const String fifteenMinutesLabel = '15 minutes';
  static const String thirtyMinutesLabel = '30 minutes';

  // Interval options for selection
  static const Map<int, String> intervalOptions = {
    fifteenMinutes: fifteenMinutesLabel,
    thirtyMinutes: thirtyMinutesLabel,
  };

  // Private constructor to prevent instantiation
  IntervalConstants._();
}
