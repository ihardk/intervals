import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_action.dart';
import '../../domain/entities/scheduled_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../services/notification_service.dart';

/// Implementation of NotificationRepository
/// Handles notification scheduling and management
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService notificationService;

  // Store last action for retrieval
  String? _lastAction;

  NotificationRepositoryImpl({required this.notificationService}) {
    // Set up callbacks
    notificationService.onNotificationAction = (action) {
      _lastAction = action;
    };
    notificationService.onNotificationTap = (payload) {
      _lastAction = null; // Regular tap, no specific action
    };
  }

  @override
  Future<Either<Failure, bool>> initialize() async {
    try {
      final result = await notificationService.initialize();
      return Right(result);
    } catch (e) {
      return Left(
        NotificationFailure('Failed to initialize notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final result = await notificationService.requestPermissions();
      return Right(result);
    } catch (e) {
      return Left(
        PermissionFailure('Failed to request notification permissions: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> areNotificationsEnabled() async {
    try {
      final result = await notificationService.areNotificationsEnabled();
      return Right(result);
    } catch (e) {
      return Left(
        NotificationFailure('Failed to check notification status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> scheduleIntervalNotification(
    ScheduleNotificationInput input,
  ) async {
    try {
      final scheduledTime = DateTime.fromMillisecondsSinceEpoch(input.scheduledTime);

      await notificationService.scheduleNotification(
        id: input.id,
        title: input.title,
        body: input.body,
        scheduledTime: scheduledTime,
      );

      return const Right(null);
    } catch (e) {
      return Left(
        NotificationFailure('Failed to schedule notification: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> scheduleRecurringNotifications(
    int intervalDuration,
    int count,
  ) async {
    try {
      final now = DateTime.now();

      // Schedule 'count' notifications at interval intervals
      for (int i = 0; i < count; i++) {
        final scheduledTime = now.add(Duration(milliseconds: intervalDuration * (i + 1)));

        await notificationService.scheduleNotification(
          id: i + 1, // Start from ID 1
          title: 'What are you doing?',
          body: 'Tap to log your activity',
          scheduledTime: scheduledTime,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        NotificationFailure('Failed to schedule recurring notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int id) async {
    try {
      await notificationService.cancelNotification(id);
      return const Right(null);
    } catch (e) {
      return Left(
        NotificationFailure('Failed to cancel notification: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      await notificationService.cancelAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(
        NotificationFailure('Failed to cancel all notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScheduledNotification>>> getPendingNotifications() async {
    try {
      final pending = await notificationService.getPendingNotifications();

      final notifications = pending.map((req) {
        return ScheduledNotification(
          id: req.id,
          scheduledTime: 0, // Not available from flutter_local_notifications
          title: req.title ?? '',
          body: req.body ?? '',
          intervalDuration: 900000, // Default to 15 min
        );
      }).toList();

      return Right(notifications);
    } catch (e) {
      return Left(
        NotificationFailure('Failed to get pending notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationAction?>> getLastNotificationAction() async {
    try {
      if (_lastAction == null) {
        return const Right(null);
      }

      // Map action string to NotificationAction enum
      final action = switch (_lastAction!) {
        NotificationService.actionText => NotificationAction.text,
        NotificationService.actionVoice => NotificationAction.voice,
        NotificationService.actionSkip => NotificationAction.skip,
        _ => null,
      };

      // Clear last action after retrieval
      _lastAction = null;

      return Right(action);
    } catch (e) {
      return Left(
        NotificationFailure('Failed to get last notification action: ${e.toString()}'),
      );
    }
  }
}
