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
        NotificationFailure(
            'Failed to initialize notifications: ${e.toString()}'),
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
        PermissionFailure(
            'Failed to request notification permissions: ${e.toString()}'),
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
        NotificationFailure(
            'Failed to check notification status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> scheduleIntervalNotification(
    ScheduleNotificationInput input,
  ) async {
    try {
      final scheduledTime =
          DateTime.fromMillisecondsSinceEpoch(input.scheduledTime);

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
    int count, {
    int startHour = 9,
    int endHour = 21,
  }) async {
    try {
      final now = DateTime.now();

      // Get slots relative to start time, not "now"
      final slots = _calculateNotificationSlots(
        now: now,
        intervalDuration: intervalDuration,
        startHour: startHour,
        endHour: endHour,
        count: count,
      );

      // Cancel any existing notifications first
      await notificationService.cancelAllNotifications();

      // Schedule ALL notifications ahead with unique IDs
      // This ensures notifications continue even if app isn't opened
      for (int i = 0; i < slots.length; i++) {
        await notificationService.scheduleNotification(
          id: i + 1, // Unique IDs starting from 1
          title: 'What are you doing?',
          body: 'log your activity',
          scheduledTime: slots[i],
        );
      }

      print('NotificationRepository: Scheduled ${slots.length} notifications');

      return const Right(null);
    } catch (e) {
      return Left(
        NotificationFailure(
            'Failed to schedule recurring notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getNextNotificationTime(
    int intervalDuration,
    int startHour,
    int endHour,
  ) async {
    try {
      final now = DateTime.now();

      final slots = _calculateNotificationSlots(
        now: now,
        intervalDuration: intervalDuration,
        startHour: startHour,
        endHour: endHour,
        count: 1, // We only need the next one
      );

      if (slots.isNotEmpty) {
        return Right(slots.first);
      }

      return const Right(null);
    } catch (e) {
      return Left(
        NotificationFailure(
            'Failed to get next notification time: ${e.toString()}'),
      );
    }
  }

  /// Helper to calculate deterministic slots
  List<DateTime> _calculateNotificationSlots({
    required DateTime now,
    required int intervalDuration,
    required int startHour,
    required int endHour,
    required int count,
  }) {
    final List<DateTime> scheduledSlots = [];

    // Safety check for invalid intervals
    if (intervalDuration < 60000) return []; // Minimum 1 minute

    // We look ahead up to 2 days to find slots
    for (int dayOffset = 0; dayOffset <= 2; dayOffset++) {
      if (scheduledSlots.length >= count) break;

      final date = now.add(Duration(days: dayOffset));

      // Construct the start time for this day
      // Active hours start at startHour:00
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        startHour,
        0,
      );

      // Generate slots for this day starting from startTime + interval
      // The user wants "start 15min after active hours" -> startHour + interval

      // Calculate how many intervals fit in the day or active period
      // If startHour < endHour (e.g. 9 to 21), duration is (end - start) hours
      // If startHour > endHour (e.g. 21 to 9), duration is (24 - start + end) hours

      // Let's just iterate by adding intervals until we hit the end condition

      DateTime currentSlot =
          startTime.add(Duration(milliseconds: intervalDuration));

      // Safety limit for loop
      int loopLimit = 0;
      while (loopLimit < 1000) {
        loopLimit++;

        // Check if slot exceeds the "active window" for this "session"
        // A simple way is to check if it's still "active"
        if (!_isActive(currentSlot.hour, startHour, endHour)) {
          // If we've passed the active window, stop for this day
          // But wait, if 21 to 9, we might cross midnight.
          // Let's define "Active Window" more strictly:
          // From [StartHour:00] to [EndHour:00] (?) or just hour-based check.
          break;
        }

        // Also strict check: verify the hour is actually valid
        // (The isActive check above handles this, but let's be sure we don't loop forever)

        // If slot is in the future, add it
        if (currentSlot.isAfter(now)) {
          scheduledSlots.add(currentSlot);
          if (scheduledSlots.length >= count) return scheduledSlots;
        }

        currentSlot = currentSlot.add(Duration(milliseconds: intervalDuration));
      }
    }

    return scheduledSlots;
  }

  bool _isActive(int hour, int start, int end) {
    if (start <= end) {
      return hour >= start && hour < end;
    } else {
      // e.g. 21 down to 9
      return hour >= start || hour < end;
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
        NotificationFailure(
            'Failed to cancel all notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScheduledNotification>>>
      getPendingNotifications() async {
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
        NotificationFailure(
            'Failed to get pending notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationAction?>>
      getLastNotificationAction() async {
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
        NotificationFailure(
            'Failed to get last notification action: ${e.toString()}'),
      );
    }
  }
}
