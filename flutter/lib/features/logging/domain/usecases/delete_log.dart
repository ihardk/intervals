import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/log_repository.dart';

/// Use case for deleting a log
class DeleteLog {
  final LogRepository repository;

  DeleteLog(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteLog(id);
  }
}
