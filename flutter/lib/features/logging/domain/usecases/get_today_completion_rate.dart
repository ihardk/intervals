import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/interval_repository.dart';

/// Use case for getting today's interval completion rate
class GetTodayCompletionRate {
  final IntervalRepository repository;

  GetTodayCompletionRate(this.repository);

  Future<Either<Failure, double>> call() {
    return repository.getTodayCompletionRate();
  }
}
