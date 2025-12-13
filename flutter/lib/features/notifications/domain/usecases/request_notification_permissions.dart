import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for requesting notification permissions
class RequestNotificationPermissions {
  final NotificationRepository repository;

  RequestNotificationPermissions(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.requestPermissions();
  }
}
