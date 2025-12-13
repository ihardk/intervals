import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log.dart';
import '../repositories/log_repository.dart';

/// Use case for getting logs within a date range
class GetLogsByDateRange {
  final LogRepository repository;

  GetLogsByDateRange(this.repository);

  Future<Either<Failure, List<Log>>> call({
    required int startTimestamp,
    required int endTimestamp,
  }) {
    return repository.getLogsByDateRange(
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
    );
  }
}
