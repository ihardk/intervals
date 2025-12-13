import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scheduled_notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting all pending notifications
class GetPendingNotifications {
  final NotificationRepository repository;

  GetPendingNotifications(this.repository);

  Future<Either<Failure, List<ScheduledNotification>>> call() {
    return repository.getPendingNotifications();
  }
}
