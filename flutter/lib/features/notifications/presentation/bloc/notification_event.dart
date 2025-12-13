import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/scheduled_notification.dart';

part 'notification_event.freezed.dart';

@freezed
class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.initialize() = InitializeNotifications;
  const factory NotificationEvent.requestPermissions() = RequestPermissions;
  const factory NotificationEvent.scheduleNotification(
    ScheduleNotificationInput input,
  ) = ScheduleNotification;
  const factory NotificationEvent.scheduleRecurring({
    required int intervalDuration,
    required int count,
  }) = ScheduleRecurring;
  const factory NotificationEvent.cancelNotification(int id) = CancelNotification;
  const factory NotificationEvent.cancelAll() = CancelAll;
  const factory NotificationEvent.loadPendingNotifications() = LoadPendingNotifications;
  const factory NotificationEvent.checkStatus() = CheckNotificationStatus;
}
