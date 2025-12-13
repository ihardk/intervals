import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for scheduling recurring interval notifications
class ScheduleRecurringNotifications {
  final NotificationRepository repository;

  ScheduleRecurringNotifications(this.repository);

  /// Schedule recurring notifications
  /// [intervalDuration] - Duration in milliseconds (900000 for 15min, 1800000 for 30min)
  /// [count] - Number of notifications to schedule ahead
  Future<Either<Failure, void>> call(int intervalDuration, int count) {
    return repository.scheduleRecurringNotifications(intervalDuration, count);
  }
}
