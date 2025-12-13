import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/export_repository.dart';

class ExportToCSV {
  final ExportRepository repository;

  ExportToCSV(this.repository);

  Future<Either<Failure, String>> call({
    required String startDate,
    required String endDate,
  }) {
    return repository.exportToCSV(startDate: startDate, endDate: endDate);
  }
}
