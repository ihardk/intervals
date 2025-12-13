import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/export_repository.dart';

class ExportToJSON {
  final ExportRepository repository;

  ExportToJSON(this.repository);

  Future<Either<Failure, String>> call({
    required String startDate,
    required String endDate,
  }) {
    return repository.exportToJSON(startDate: startDate, endDate: endDate);
  }
}
