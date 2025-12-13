import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/insight.dart';

/// Repository interface for Insight operations
/// Manages pre-computed analytics and insights
abstract class InsightRepository {
  /// Get an insight by ID
  Future<Either<Failure, Insight>> getInsightById(String id);

  /// Get insight by type and date
  Future<Either<Failure, Insight?>> getInsight({
    required String insightType,
    required String date,
  });

  /// Get all insights of a specific type
  Future<Either<Failure, List<Insight>>> getInsightsByType({
    required String insightType,
    int limit = 30,
  });

  /// Get daily insights for a date range
  Future<Either<Failure, List<Insight>>> getDailyInsights({
    required String startDate,
    required String endDate,
  });

  /// Get today's insight
  Future<Either<Failure, Insight?>> getTodayInsight();

  /// Get this week's insight
  Future<Either<Failure, Insight?>> getWeeklyInsight();

  /// Get this month's insight
  Future<Either<Failure, Insight?>> getMonthlyInsight();

  /// Upsert (insert or update) an insight
  Future<Either<Failure, void>> upsertInsight({
    required String id,
    required String insightType,
    required String date,
    required String data,
    int? expiresAt,
  });

  /// Generate and save daily insight
  Future<Either<Failure, Insight>> generateDailyInsight(DateTime date);

  /// Delete expired insights (cleanup)
  Future<Either<Failure, int>> deleteExpiredInsights();

  /// Delete insights by type
  Future<Either<Failure, int>> deleteInsightsByType(String insightType);

  /// Get insights count
  Future<Either<Failure, int>> getInsightsCount();

  /// Watch insights by type (reactive stream)
  Stream<Either<Failure, List<Insight>>> watchInsightsByType({
    required String insightType,
    int limit = 30,
  });
}
