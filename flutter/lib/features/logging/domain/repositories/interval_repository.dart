import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/interval.dart';

/// Repository interface for Interval operations
/// Manages notification intervals and user responses
abstract class IntervalRepository {
  /// Create a new interval
  Future<Either<Failure, Interval>> createInterval({
    required int scheduledTime,
    required int intervalDuration,
    int? actualTime,
  });

  /// Get an interval by ID
  Future<Either<Failure, Interval>> getIntervalById(String id);

  /// Get the next upcoming interval
  Future<Either<Failure, Interval?>> getNextInterval();

  /// Get all intervals for today
  Future<Either<Failure, List<Interval>>> getTodayIntervals();

  /// Get intervals for a date range
  Future<Either<Failure, List<Interval>>> getIntervalsByDateRange({
    required int startTimestamp,
    required int endTimestamp,
  });

  /// Complete an interval with response
  Future<Either<Failure, void>> completeInterval({
    required String id,
    required String responseType,
    required int responseTime,
    String? logId,
  });

  /// Get completion rate for a specific date
  Future<Either<Failure, double>> getCompletionRate(DateTime date);

  /// Get today's completion rate
  Future<Either<Failure, double>> getTodayCompletionRate();

  /// Get skipped intervals count for a time period
  Future<Either<Failure, int>> getSkippedCount({
    required int startTimestamp,
    required int endTimestamp,
  });

  /// Delete old intervals (cleanup)
  Future<Either<Failure, int>> purgeOldIntervals(int olderThanDays);

  /// Watch upcoming intervals (reactive stream)
  Stream<Either<Failure, List<Interval>>> watchUpcomingIntervals();

  /// Watch today's intervals (reactive stream)
  Stream<Either<Failure, List<Interval>>> watchTodayIntervals();
}
