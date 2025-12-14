import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class GetNextNotificationTime {
  final NotificationRepository repository;

  GetNextNotificationTime(this.repository);

  Future<Either<Failure, DateTime?>> call(
    int intervalDuration,
    int startHour,
    int endHour,
  ) async {
    return await repository.getNextNotificationTime(
      intervalDuration,
      startHour,
      endHour,
    );
  }
}
