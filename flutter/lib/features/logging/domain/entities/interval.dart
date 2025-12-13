import 'package:freezed_annotation/freezed_annotation.dart';

part 'interval.freezed.dart';

/// Response type enumeration
enum ResponseType {
  @JsonValue('logged')
  logged,
  @JsonValue('skipped')
  skipped,
  @JsonValue('ignored')
  ignored,
}

/// Interval entity - represents a notification interval and user response
/// All timestamps are in milliseconds (Unix epoch)
@freezed
class Interval with _$Interval {
  const factory Interval({
    required String id, // UUID v4
    required int scheduledTime, // When notification should fire (Unix ms)
    int? actualTime, // When notification actually fired (Unix ms)
    int? responseTime, // When user responded (Unix ms)
    ResponseType? responseType, // How user responded
    String? logId, // Foreign key to Log if user logged
    required int intervalDuration, // 900000 (15min) or 1800000 (30min)
    @Default(false) bool isCompleted, // Whether interval was handled
    required int createdAt, // Creation timestamp
  }) = _Interval;

  const Interval._();

  /// Check if user logged for this interval
  bool get wasLogged => responseType == ResponseType.logged;

  /// Check if user skipped this interval
  bool get wasSkipped => responseType == ResponseType.skipped;

  /// Check if interval was ignored
  bool get wasIgnored => responseType == ResponseType.ignored;

  /// Check if notification was delivered on time
  bool get wasOnTime {
    if (actualTime == null) return false;
    final difference = actualTime! - scheduledTime;
    return difference.abs() < 60000; // Within 1 minute
  }

  /// Get response delay in milliseconds
  int? get responseDelay {
    if (responseTime == null || actualTime == null) return null;
    return responseTime! - actualTime!;
  }
}

/// Input for creating a new interval
@freezed
class CreateIntervalInput with _$CreateIntervalInput {
  const factory CreateIntervalInput({
    required int scheduledTime,
    required int intervalDuration,
  }) = _CreateIntervalInput;
}

/// Input for completing an interval
@freezed
class CompleteIntervalInput with _$CompleteIntervalInput {
  const factory CompleteIntervalInput({
    required String id,
    required ResponseType responseType,
    required int responseTime,
    String? logId,
  }) = _CompleteIntervalInput;
}
