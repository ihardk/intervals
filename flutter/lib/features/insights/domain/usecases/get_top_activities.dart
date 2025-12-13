import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/insight.dart';
import '../repositories/insight_repository.dart';

class GetTopActivities {
  final InsightRepository repository;

  GetTopActivities(this.repository);

  Future<Either<Failure, List<ActivityCount>>> call(DateTime date) async {
    final result = await repository.generateDailyInsight(date);
    return result.map((insight) => insight.data.topActivities);
  }
}
