import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/insight_repository.dart';

class CalculateCompletionRate {
  final InsightRepository repository;

  CalculateCompletionRate(this.repository);

  Future<Either<Failure, double>> call(DateTime date) async {
    throw UnimplementedError();
  }
}
