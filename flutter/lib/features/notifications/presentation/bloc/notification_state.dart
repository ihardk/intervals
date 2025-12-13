import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/scheduled_notification.dart';

part 'notification_state.freezed.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = NotificationInitial;
  const factory NotificationState.loading() = NotificationLoading;
  const factory NotificationState.initialized({
    @Default(false) bool permissionsGranted,
    @Default(false) bool notificationsEnabled,
  }) = NotificationInitialized;
  const factory NotificationState.scheduled() = NotificationScheduled;
  const factory NotificationState.cancelled() = NotificationCancelled;
  const factory NotificationState.pending(
    List<ScheduledNotification> notifications,
  ) = NotificationPending;
  const factory NotificationState.permissionDenied() = NotificationPermissionDenied;
  const factory NotificationState.error(String message) = NotificationError;
}
