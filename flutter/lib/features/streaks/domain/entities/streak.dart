import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak.freezed.dart';
part 'streak.g.dart';

/// Streak type enumeration
enum StreakType {
  @JsonValue('daily_logs')
  dailyLogs,
  @JsonValue('consistent_intervals')
  consistentIntervals,
  @JsonValue('no_skip')
  noSkip,
}

/// Streak entity - represents user consistency tracking
@freezed
class Streak with _$Streak {
  const factory Streak({
    required String id, // UUID v4
    required StreakType streakType,
    required String startDate, // ISO date (YYYY-MM-DD)
    String? endDate, // ISO date (YYYY-MM-DD), null if ongoing
    required int currentCount, // Current streak count
    required int bestCount, // Best streak ever achieved
    @Default(true) bool isActive, // Whether streak is currently active
    required int createdAt, // Creation timestamp
    required int updatedAt, // Last update timestamp
  }) = _Streak;

  const Streak._();

  /// Create from JSON
  factory Streak.fromJson(Map<String, dynamic> json) =>
      _$StreakFromJson(json);

  /// Check if streak is ongoing
  bool get isOngoing => endDate == null && isActive;

  /// Check if streak is broken
  bool get isBroken => !isActive;

  /// Check if current streak is personal best
  bool get isPersonalBest => currentCount == bestCount && currentCount > 0;

  /// Get streak duration in days
  int get durationDays {
    if (endDate == null) {
      final now = DateTime.now();
      final start = DateTime.parse(startDate);
      return now.difference(start).inDays + 1;
    }
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate!);
    return end.difference(start).inDays + 1;
  }

  /// Get friendly streak type name
  String get typeName {
    switch (streakType) {
      case StreakType.dailyLogs:
        return 'Daily Logs';
      case StreakType.consistentIntervals:
        return 'Consistent Intervals';
      case StreakType.noSkip:
        return 'No Skip';
    }
  }

  /// Get streak description
  String get description {
    if (isOngoing) {
      return '$currentCount ${currentCount == 1 ? 'day' : 'days'} streak';
    }
    return 'Ended on $endDate after $currentCount ${currentCount == 1 ? 'day' : 'days'}';
  }
}

/// Input for creating a new streak
@freezed
class CreateStreakInput with _$CreateStreakInput {
  const factory CreateStreakInput({
    required StreakType streakType,
    required String startDate,
    @Default(1) int currentCount,
    @Default(1) int bestCount,
  }) = _CreateStreakInput;
}

/// Input for updating a streak
@freezed
class UpdateStreakInput with _$UpdateStreakInput {
  const factory UpdateStreakInput({
    required String id,
    int? currentCount,
    int? bestCount,
    bool? isActive,
    String? endDate,
  }) = _UpdateStreakInput;
}
