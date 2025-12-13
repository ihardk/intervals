import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for initializing notification service
class InitializeNotifications {
  final NotificationRepository repository;

  InitializeNotifications(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.initialize();
  }
}
