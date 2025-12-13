import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/daos/insights_dao.dart';
import '../../../../core/database/daos/logs_dao.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/insight.dart' as domain;
import '../../domain/repositories/insight_repository.dart';

/// Implementation of InsightRepository
/// Handles insight generation and retrieval
class InsightRepositoryImpl implements InsightRepository {
  final InsightsDao insightsDao;
  final LogsDao logsDao;

  InsightRepositoryImpl({
    required this.insightsDao,
    required this.logsDao,
  });

  @override
  Future<Either<Failure, domain.Insight>> getInsightById(String id) async {
    try {
      final insightData = await insightsDao.getInsightById(id);

      if (insightData == null) {
        return Left(NotFoundFailure('Insight not found with id: $id'));
      }

      return Right(_mapToDomain(insightData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get insight: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Insight?>> getInsight({
    required String insightType,
    required String date,
  }) async {
    try {
      final insightData = await insightsDao.getInsight(insightType, date);
      return Right(insightData != null ? _mapToDomain(insightData) : null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get insight: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Insight>>> getInsightsByType({
    required String insightType,
    int limit = 30,
  }) async {
    try {
      final insightsData = await insightsDao.getInsightsByType(insightType, limit: limit);
      final insights = insightsData.map(_mapToDomain).toList();
      return Right(insights);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get insights by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Insight>>> getDailyInsights({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final insightsData = await insightsDao.getDailyInsights(
        startDate,
        endDate,
      );
      final insights = insightsData.map(_mapToDomain).toList();
      return Right(insights);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get daily insights: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Insight?>> getTodayInsight() async {
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getInsight(insightType: 'daily', date: dateString);
  }

  @override
  Future<Either<Failure, domain.Insight?>> getWeeklyInsight() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dateString =
        '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}';
    return getInsight(insightType: 'weekly', date: dateString);
  }

  @override
  Future<Either<Failure, domain.Insight?>> getMonthlyInsight() async {
    final now = DateTime.now();
    final dateString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    return getInsight(insightType: 'monthly', date: dateString);
  }

  @override
  Future<Either<Failure, void>> upsertInsight({
    required String id,
    required String insightType,
    required String date,
    required String data,
    int? expiresAt,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await insightsDao.upsertInsight(
        InsightsCompanion.insert(
          id: id,
          insightType: insightType,
          date: date,
          data: data,
          createdAt: now,
          expiresAt: Value(expiresAt),
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to upsert insight: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Insight>> generateDailyInsight(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      final endOfDay = startOfDay + 86400000;

      final logs = await logsDao.getLogsByDateRange(startOfDay, endOfDay);

      // Calculate stats
      final totalLogs = logs.length;
      final Map<String, int> categoryCounts = {};

      for (final log in logs) {
        if (log.category != null) {
          categoryCounts[log.category!] = (categoryCounts[log.category!] ?? 0) + 1;
        }
      }

      final insightData = {
        'total_logs': totalLogs,
        'category_distribution': categoryCounts,
        'date': date.toIso8601String(),
      };

      final insightId = const Uuid().v4();
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      await upsertInsight(
        id: insightId,
        insightType: 'daily',
        date: dateString,
        data: jsonEncode(insightData),
      );

      final createdInsight = await insightsDao.getInsightById(insightId);

      if (createdInsight == null) {
        return const Left(DatabaseFailure('Failed to retrieve generated insight'));
      }

      return Right(_mapToDomain(createdInsight));
    } catch (e) {
      return Left(DatabaseFailure('Failed to generate daily insight: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteExpiredInsights() async {
    try {
      final count = await insightsDao.deleteExpiredInsights();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete expired insights: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteInsightsByType(String insightType) async {
    try {
      final count = await insightsDao.deleteInsightsByType(insightType);
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete insights by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getInsightsCount() async {
    try {
      final count = await insightsDao.getInsightsCount();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get insights count: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<domain.Insight>>> watchInsightsByType({
    required String insightType,
    int limit = 30,
  }) {
    try {
      return insightsDao.watchInsightsByType(insightType, limit: limit).map(
        (insightsData) => Right(insightsData.map(_mapToDomain).toList()),
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch insights: ${e.toString()}')),
      );
    }
  }

  /// Map Drift InsightData to domain Insight entity
  domain.Insight _mapToDomain(InsightData data) {
    // Convert string to enum
    final insightType = _stringToInsightType(data.insightType);

    // Parse JSON data to InsightData
    domain.InsightData insightData;
    try {
      final Map<String, dynamic> dataMap = jsonDecode(data.data) as Map<String, dynamic>;
      insightData = domain.InsightData.fromJson(dataMap);
    } catch (e) {
      // If parsing fails, create default InsightData
      insightData = const domain.InsightData(totalLogs: 0);
    }

    return domain.Insight(
      id: data.id,
      insightType: insightType,
      date: data.date,
      data: insightData,
      expiresAt: data.expiresAt,
      createdAt: data.createdAt,
    );
  }

  /// Convert string to InsightType enum
  domain.InsightType _stringToInsightType(String value) {
    switch (value) {
      case 'daily':
        return domain.InsightType.daily;
      case 'weekly':
        return domain.InsightType.weekly;
      case 'monthly':
        return domain.InsightType.monthly;
      case 'pattern':
        return domain.InsightType.pattern;
      default:
        return domain.InsightType.daily;
    }
  }
}
