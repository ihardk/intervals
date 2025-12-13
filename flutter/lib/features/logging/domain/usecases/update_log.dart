import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log.dart';
import '../repositories/log_repository.dart';

/// Use case for updating an existing log
class UpdateLog {
  final LogRepository repository;

  UpdateLog(this.repository);

  Future<Either<Failure, void>> call(Log log) {
    return repository.updateLog(log);
  }
}
