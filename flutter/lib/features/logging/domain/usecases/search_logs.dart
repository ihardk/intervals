import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log.dart';
import '../repositories/log_repository.dart';

/// Use case for searching logs by content
class SearchLogs {
  final LogRepository repository;

  SearchLogs(this.repository);

  Future<Either<Failure, List<Log>>> call(String query) {
    return repository.searchLogs(query);
  }
}
