import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/interval_repository.dart';

/// Use case for completing an interval with user response
class CompleteInterval {
  final IntervalRepository repository;

  CompleteInterval(this.repository);

  Future<Either<Failure, void>> call({
    required String id,
    required String responseType,
    required int responseTime,
    String? logId,
  }) {
    return repository.completeInterval(
      id: id,
      responseType: responseType,
      responseTime: responseTime,
      logId: logId,
    );
  }
}
