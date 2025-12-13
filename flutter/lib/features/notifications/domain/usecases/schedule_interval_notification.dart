import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scheduled_notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for scheduling a single interval notification
class ScheduleIntervalNotification {
  final NotificationRepository repository;

  ScheduleIntervalNotification(this.repository);

  Future<Either<Failure, void>> call(ScheduleNotificationInput input) {
    return repository.scheduleIntervalNotification(input);
  }
}
