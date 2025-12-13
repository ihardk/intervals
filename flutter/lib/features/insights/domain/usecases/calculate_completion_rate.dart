import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/insight_repository.dart';

class CalculateCompletionRate {
  final InsightRepository repository;

  CalculateCompletionRate(this.repository);

  Future<Either<Failure, double>> call(DateTime date) async {
    final result = await repository.generateDailyInsight(date);
    return result.map((insight) => insight.data.completionRate);
  }
}
