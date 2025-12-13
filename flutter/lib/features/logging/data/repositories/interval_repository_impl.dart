import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/daos/intervals_dao.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/interval.dart' as domain;
import '../../domain/repositories/interval_repository.dart';

/// Implementation of IntervalRepository
/// Handles interval tracking and completion statistics
class IntervalRepositoryImpl implements IntervalRepository {
  final IntervalsDao intervalsDao;

  IntervalRepositoryImpl({required this.intervalsDao});

  @override
  Future<Either<Failure, domain.Interval>> createInterval({
    required int scheduledTime,
    required int intervalDuration,
    int? actualTime,
  }) async {
    try {
      final intervalId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      final intervalCompanion = IntervalsCompanion.insert(
        id: intervalId,
        scheduledTime: scheduledTime,
        intervalDuration: intervalDuration,
        actualTime: Value(actualTime),
        createdAt: now,
      );

      await intervalsDao.insertInterval(intervalCompanion);
      final intervalData = await intervalsDao.getIntervalById(intervalId);

      if (intervalData == null) {
        return const Left(DatabaseFailure('Failed to retrieve created interval'));
      }

      return Right(_mapToDomain(intervalData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to create interval: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Interval>> getIntervalById(String id) async {
    try {
      final intervalData = await intervalsDao.getIntervalById(id);

      if (intervalData == null) {
        return Left(NotFoundFailure('Interval not found with id: $id'));
      }

      return Right(_mapToDomain(intervalData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get interval: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Interval?>> getNextInterval() async {
    try {
      final intervalData = await intervalsDao.getNextInterval();
      return Right(intervalData != null ? _mapToDomain(intervalData) : null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get next interval: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Interval>>> getTodayIntervals() async {
    try {
      final intervalsData = await intervalsDao.getTodayIntervals();
      final intervals = intervalsData.map(_mapToDomain).toList();
      return Right(intervals);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get today intervals: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Interval>>> getIntervalsByDateRange({
    required int startTimestamp,
    required int endTimestamp,
  }) async {
    try {
      final intervalsData = await intervalsDao.getIntervalsByDateRange(
        startTimestamp,
        endTimestamp,
      );
      final intervals = intervalsData.map(_mapToDomain).toList();
      return Right(intervals);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get intervals by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> completeInterval({
    required String id,
    required String responseType,
    required int responseTime,
    String? logId,
  }) async {
    try {
      await intervalsDao.completeInterval(
        id: id,
        responseType: responseType,
        responseTime: responseTime,
        logId: logId,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to complete interval: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getCompletionRate(DateTime date) async {
    try {
      final rate = await intervalsDao.getCompletionRate(date);
      return Right(rate);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get completion rate: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTodayCompletionRate() async {
    return getCompletionRate(DateTime.now());
  }

  @override
  Future<Either<Failure, int>> getSkippedCount({
    required int startTimestamp,
    required int endTimestamp,
  }) async {
    try {
      final count = await intervalsDao.getSkippedCount(
        startTimestamp,
        endTimestamp,
      );
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get skipped count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> purgeOldIntervals(int olderThanDays) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      final count = await intervalsDao.deleteOldIntervals(cutoffDate);
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to purge old intervals: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<domain.Interval>>> watchUpcomingIntervals() {
    try {
      return intervalsDao.watchUpcomingIntervals().map(
        (intervalsData) => Right(intervalsData.map(_mapToDomain).toList()),
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch upcoming intervals: ${e.toString()}')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<domain.Interval>>> watchTodayIntervals() {
    try {
      return intervalsDao.watchTodayIntervals().map(
        (intervalsData) => Right(intervalsData.map(_mapToDomain).toList()),
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch today intervals: ${e.toString()}')),
      );
    }
  }

  /// Map Drift IntervalData to domain Interval entity
  domain.Interval _mapToDomain(IntervalData data) {
    return domain.Interval(
      id: data.id,
      scheduledTime: data.scheduledTime,
      actualTime: data.actualTime,
      intervalDuration: data.intervalDuration,
      isCompleted: data.isCompleted == 1,
      responseType: data.responseType,
      responseTime: data.responseTime,
      logId: data.logId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
