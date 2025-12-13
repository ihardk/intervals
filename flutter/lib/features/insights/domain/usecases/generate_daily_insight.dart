import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/insight.dart';
import '../repositories/insight_repository.dart';

class GenerateDailyInsight {
  final InsightRepository repository;

  GenerateDailyInsight(this.repository);

  Future<Either<Failure, Insight>> call(DateTime date) async {
    throw UnimplementedError();
  }
}
