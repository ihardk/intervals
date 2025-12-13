import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for canceling all scheduled notifications
class CancelAllNotifications {
  final NotificationRepository repository;

  CancelAllNotifications(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.cancelAllNotifications();
  }
}
