import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/interval.dart';
import '../repositories/interval_repository.dart';

/// Use case for creating an interval
class CreateInterval {
  final IntervalRepository repository;

  CreateInterval(this.repository);

  Future<Either<Failure, Interval>> call({
    required int scheduledTime,
    required int intervalDuration,
    int? actualTime,
  }) {
    return repository.createInterval(
      scheduledTime: scheduledTime,
      intervalDuration: intervalDuration,
      actualTime: actualTime,
    );
  }
}
