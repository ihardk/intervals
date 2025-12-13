import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/log.dart';

/// Repository interface for Log operations
/// Defines the contract for log data operations
abstract class LogRepository {
  /// Create a new log entry
  /// Returns Either<Failure, Log> - Left for errors, Right for success
  Future<Either<Failure, Log>> createLog({
    required String content,
    required String entryType,
    String? audioPath,
    String? category,
    List<String>? tags,
    String? mood,
    int? timestamp,
  });

  /// Get all logs for today
  Future<Either<Failure, List<Log>>> getTodayLogs();

  /// Get a specific log by ID
  Future<Either<Failure, Log>> getLogById(String id);

  /// Get logs for a specific date range
  Future<Either<Failure, List<Log>>> getLogsByDateRange({
    required int startTimestamp,
    required int endTimestamp,
  });

  /// Get logs by category
  Future<Either<Failure, List<Log>>> getLogsByCategory(String category);

  /// Search logs by content
  Future<Either<Failure, List<Log>>> searchLogs(String query);

  /// Update an existing log
  Future<Either<Failure, void>> updateLog(Log log);

  /// Soft delete a log
  Future<Either<Failure, void>> deleteLog(String id);

  /// Get total logs count
  Future<Either<Failure, int>> getLogsCount();

  /// Get logs count for a date range
  Future<Either<Failure, int>> getLogsCountByDateRange({
    required int startTimestamp,
    required int endTimestamp,
  });

  /// Watch today's logs (reactive stream)
  Stream<Either<Failure, List<Log>>> watchTodayLogs();
}
