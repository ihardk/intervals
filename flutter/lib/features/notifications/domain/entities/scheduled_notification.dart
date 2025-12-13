import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduled_notification.freezed.dart';

/// Scheduled notification entity - represents a pending notification
@freezed
class ScheduledNotification with _$ScheduledNotification {
  const factory ScheduledNotification({
    required int id, // Notification ID
    required int scheduledTime, // When notification should fire (Unix ms)
    required String title,
    required String body,
    required int intervalDuration, // 900000 (15min) or 1800000 (30min)
    @Default(true) bool isActive, // Whether notification is still scheduled
  }) = _ScheduledNotification;

  const ScheduledNotification._();

  /// Check if notification is in the past
  bool get isPast {
    return scheduledTime < DateTime.now().millisecondsSinceEpoch;
  }

  /// Check if notification is in the future
  bool get isFuture {
    return scheduledTime > DateTime.now().millisecondsSinceEpoch;
  }

  /// Time until notification fires in milliseconds
  int get timeUntilFire {
    return scheduledTime - DateTime.now().millisecondsSinceEpoch;
  }
}

/// Input for scheduling a notification
@freezed
class ScheduleNotificationInput with _$ScheduleNotificationInput {
  const factory ScheduleNotificationInput({
    required int id,
    required int scheduledTime,
    required String title,
    required String body,
    required int intervalDuration,
  }) = _ScheduleNotificationInput;
}
