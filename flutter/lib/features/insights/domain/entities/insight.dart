import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight.freezed.dart';
part 'insight.g.dart';

/// Insight type enumeration
enum InsightType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('pattern')
  pattern,
}

/// Insight entity - represents pre-computed analytics
@freezed
class Insight with _$Insight {
  const factory Insight({
    required String id, // UUID v4
    required InsightType insightType,
    required String date, // ISO date (YYYY-MM-DD)
    required InsightData data, // Insight details
    required int createdAt, // Creation timestamp
    int? expiresAt, // Optional cache expiration
  }) = _Insight;

  const Insight._();

  /// Check if insight is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiresAt!;
  }

  /// Check if insight is for today
  bool get isToday {
    final now = DateTime.now();
    final insightDate = DateTime.parse(date);
    return insightDate.year == now.year &&
        insightDate.month == now.month &&
        insightDate.day == now.day;
  }

  /// Create from JSON
  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}

/// Insight data containing statistics and patterns
@freezed
class InsightData with _$InsightData {
  const factory InsightData({
    required int totalLogs,
    @Default(0) int skippedIntervals,
    @Default(0.0) double completionRate,
    @Default(0) int streakDays,
    @Default([])
    List<int> weeklyActivity, // Past 7 days log counts (index 0 = today)
    @Default([]) List<ActivityCount> topActivities,
    double? productivityScore,
    @Default([]) List<int> peakHours,
    @Default([]) List<int> distractionPeriods,
  }) = _InsightData;

  const InsightData._();

  /// Create from JSON
  factory InsightData.fromJson(Map<String, dynamic> json) =>
      _$InsightDataFromJson(json);

  /// Get completion percentage (0-100)
  int get completionPercentage => (completionRate * 100).round();

  /// Check if user is on a streak
  bool get hasStreak => streakDays > 0;

  /// Get top 3 activities
  List<ActivityCount> get top3Activities => topActivities.take(3).toList();
}

/// Activity count for top activities
@freezed
class ActivityCount with _$ActivityCount {
  const factory ActivityCount({
    required String activity,
    required int count,
  }) = _ActivityCount;

  const ActivityCount._();

  /// Create from JSON
  factory ActivityCount.fromJson(Map<String, dynamic> json) =>
      _$ActivityCountFromJson(json);
}

/// Time distribution for pattern analysis
@freezed
class TimeDistribution with _$TimeDistribution {
  const factory TimeDistribution({
    required int hour,
    required int count,
    @Default(0.0) double percentage,
  }) = _TimeDistribution;

  const TimeDistribution._();

  /// Create from JSON
  factory TimeDistribution.fromJson(Map<String, dynamic> json) =>
      _$TimeDistributionFromJson(json);
}

/// Pattern detection result
@freezed
class PatternDetectionResult with _$PatternDetectionResult {
  const factory PatternDetectionResult({
    @Default([]) List<int> peakHours,
    @Default([]) List<int> distractionPeriods,
    @Default([]) List<String> recurringActivities,
    @Default({}) Map<String, int> timeDistribution,
  }) = _PatternDetectionResult;

  const PatternDetectionResult._();

  /// Create from JSON
  factory PatternDetectionResult.fromJson(Map<String, dynamic> json) =>
      _$PatternDetectionResultFromJson(json);
}
