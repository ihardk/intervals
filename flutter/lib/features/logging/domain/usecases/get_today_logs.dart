import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log.dart';
import '../repositories/log_repository.dart';

/// Use case for getting today's logs
class GetTodayLogs {
  final LogRepository repository;

  GetTodayLogs(this.repository);

  Future<Either<Failure, List<Log>>> call() {
    return repository.getTodayLogs();
  }
}
