import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_action.dart';
import '../entities/scheduled_notification.dart';

/// Repository interface for notification operations
abstract class NotificationRepository {
  /// Initialize notification service and request permissions
  Future<Either<Failure, bool>> initialize();

  /// Request notification permissions from user
  Future<Either<Failure, bool>> requestPermissions();

  /// Check if notifications are enabled
  Future<Either<Failure, bool>> areNotificationsEnabled();

  /// Schedule a single interval notification
  Future<Either<Failure, void>> scheduleIntervalNotification(
    ScheduleNotificationInput input,
  );

  /// Schedule recurring interval notifications
  Future<Either<Failure, void>> scheduleRecurringNotifications(
    int intervalDuration,
    int count,
  );

  /// Cancel a specific notification by ID
  Future<Either<Failure, void>> cancelNotification(int id);

  /// Cancel all scheduled notifications
  Future<Either<Failure, void>> cancelAllNotifications();

  /// Get all pending notifications
  Future<Either<Failure, List<ScheduledNotification>>>
      getPendingNotifications();

  /// Handle notification response (tap or action)
  Future<Either<Failure, NotificationAction?>> getLastNotificationAction();
}
