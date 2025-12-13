import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

/// Repository interface for Export operations
/// Manages data export and export history
abstract class ExportRepository {
  /// Export logs to CSV format
  /// Returns the file path of the exported CSV
  Future<Either<Failure, String>> exportToCSV({
    required String startDate,
    required String endDate,
  });

  /// Export logs to JSON format
  /// Returns the file path of the exported JSON
  Future<Either<Failure, String>> exportToJSON({
    required String startDate,
    required String endDate,
  });

  /// Get export history
  Future<Either<Failure, List<ExportRecord>>> getExportHistory();

  /// Get exports by type (csv or json)
  Future<Either<Failure, List<ExportRecord>>> getExportsByType(String type);

  /// Get recent exports
  Future<Either<Failure, List<ExportRecord>>> getRecentExports({int limit = 10});

  /// Delete old export files and records
  Future<Either<Failure, int>> deleteOldExports(int olderThanDays);

  /// Delete a specific export
  Future<Either<Failure, void>> deleteExport(String id);

  /// Get total exported records count
  Future<Either<Failure, int>> getTotalExportedRecords();

  /// Get total export file size
  Future<Either<Failure, int>> getTotalExportSize();
}

/// Export record model for domain layer
class ExportRecord {
  final String id;
  final String exportType;
  final String filePath;
  final String dateRangeStart;
  final String dateRangeEnd;
  final int? recordCount;
  final int? fileSize;
  final int createdAt;

  const ExportRecord({
    required this.id,
    required this.exportType,
    required this.filePath,
    required this.dateRangeStart,
    required this.dateRangeEnd,
    this.recordCount,
    this.fileSize,
    required this.createdAt,
  });
}
