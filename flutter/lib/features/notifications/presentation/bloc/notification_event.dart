import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/scheduled_notification.dart';

part 'notification_event.freezed.dart';

@freezed
class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.initialize() = InitializeNotificationsEvent;
  const factory NotificationEvent.requestPermissions() =
      RequestPermissionsEvent;
  const factory NotificationEvent.scheduleNotification(
    ScheduleNotificationInput input,
  ) = ScheduleNotificationEvent;
  const factory NotificationEvent.scheduleRecurring({
    required int intervalDuration,
    required int count,
  }) = ScheduleRecurringEvent;
  const factory NotificationEvent.cancelNotification(int id) =
      CancelNotificationEvent;
  const factory NotificationEvent.cancelAll() = CancelAllEvent;
  const factory NotificationEvent.loadPendingNotifications() =
      LoadPendingNotificationsEvent;
  const factory NotificationEvent.checkStatus() = CheckNotificationStatusEvent;
}
