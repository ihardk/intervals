import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/daos/streaks_dao.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/streak.dart' as domain;
import '../../domain/repositories/streak_repository.dart';

/// Implementation of StreakRepository
/// Handles streak tracking and management
class StreakRepositoryImpl implements StreakRepository {
  final StreaksDao streaksDao;

  StreakRepositoryImpl({required this.streaksDao});

  @override
  Future<Either<Failure, domain.Streak>> getStreakById(String id) async {
    try {
      final streakData = await streaksDao.getStreakById(id);

      if (streakData == null) {
        return Left(NotFoundFailure('Streak not found with id: $id'));
      }

      return Right(_mapToDomain(streakData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get streak: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Streak?>> getActiveStreak(String streakType) async {
    try {
      final streakData = await streaksDao.getActiveStreak(streakType);
      return Right(streakData != null ? _mapToDomain(streakData) : null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active streak: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Streak>>> getActiveStreaks() async {
    try {
      final streaksData = await streaksDao.getActiveStreaks();
      final streaks = streaksData.map(_mapToDomain).toList();
      return Right(streaks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active streaks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Streak>>> getStreaksByType(String streakType) async {
    try {
      final streaksData = await streaksDao.getStreaksByType(streakType);
      final streaks = streaksData.map(_mapToDomain).toList();
      return Right(streaks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get streaks by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getBestStreakCount(String streakType) async {
    try {
      final streak = await streaksDao.getActiveStreak(streakType);
      return Right(streak?.bestCount ?? 0);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get best streak count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getCurrentStreakCount(String streakType) async {
    try {
      final streak = await streaksDao.getActiveStreak(streakType);
      return Right(streak?.currentCount ?? 0);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get current streak count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isStreakActive(String streakType) async {
    try {
      final streak = await streaksDao.getActiveStreak(streakType);
      return Right(streak != null && streak.isActive == 1);
    } catch (e) {
      return Left(DatabaseFailure('Failed to check if streak is active: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, domain.Streak>> createStreak({
    required String streakType,
    required String startDate,
    int currentCount = 1,
    int bestCount = 1,
  }) async {
    try {
      final streakId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      final streakCompanion = StreaksCompanion.insert(
        id: streakId,
        streakType: streakType,
        currentCount: currentCount,
        bestCount: bestCount,
        startDate: startDate,
        isActive: const Value(1),
        createdAt: now,
        updatedAt: now,
      );

      await streaksDao.insertStreak(streakCompanion);
      final streakData = await streaksDao.getStreakById(streakId);

      if (streakData == null) {
        return const Left(DatabaseFailure('Failed to retrieve created streak'));
      }

      return Right(_mapToDomain(streakData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to create streak: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStreak(domain.Streak streak) async {
    try {
      final streakData = _mapToData(streak);
      await streaksDao.updateStreak(streakData);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update streak: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementStreak(String id) async {
    try {
      await streaksDao.incrementStreak(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to increment streak: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> breakStreak(String id) async {
    try {
      await streaksDao.breakStreak(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to break streak: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetCurrentCount(String id) async {
    try {
      await streaksDao.resetCurrentCount(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to reset current count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStreak(String id) async {
    try {
      await streaksDao.deleteStreak(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete streak: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteStreaksByType(String streakType) async {
    try {
      final count = await streaksDao.deleteStreaksByType(streakType);
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete streaks by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Streak>>> getAllStreaks() async {
    try {
      final streaksData = await streaksDao.getAllStreaks();
      final streaks = streaksData.map(_mapToDomain).toList();
      return Right(streaks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all streaks: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, domain.Streak?>> watchActiveStreak(String streakType) {
    try {
      return streaksDao.watchActiveStreak(streakType).map(
        (streakData) => Right(streakData != null ? _mapToDomain(streakData) : null),
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch active streak: ${e.toString()}')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<domain.Streak>>> watchActiveStreaks() {
    try {
      return streaksDao.watchActiveStreaks().map(
        (streaksData) => Right(streaksData.map(_mapToDomain).toList()),
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch active streaks: ${e.toString()}')),
      );
    }
  }

  /// Map Drift StreakData to domain Streak entity
  domain.Streak _mapToDomain(StreakData data) {
    return domain.Streak(
      id: data.id,
      streakType: _stringToStreakType(data.streakType),
      currentCount: data.currentCount,
      bestCount: data.bestCount,
      startDate: data.startDate,
      endDate: data.endDate,
      isActive: data.isActive == 1,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Map domain Streak entity to Drift StreakData
  StreakData _mapToData(domain.Streak streak) {
    return StreakData(
      id: streak.id,
      streakType: _streakTypeToString(streak.streakType),
      currentCount: streak.currentCount,
      bestCount: streak.bestCount,
      startDate: streak.startDate,
      endDate: streak.endDate,
      isActive: streak.isActive ? 1 : 0,
      createdAt: streak.createdAt,
      updatedAt: streak.updatedAt,
    );
  }

  /// Convert string to StreakType enum
  domain.StreakType _stringToStreakType(String value) {
    switch (value) {
      case 'daily_logs':
        return domain.StreakType.dailyLogs;
      case 'consistent_intervals':
        return domain.StreakType.consistentIntervals;
      case 'no_skip':
        return domain.StreakType.noSkip;
      default:
        return domain.StreakType.dailyLogs;
    }
  }

  /// Convert StreakType enum to string
  String _streakTypeToString(domain.StreakType type) {
    switch (type) {
      case domain.StreakType.dailyLogs:
        return 'daily_logs';
      case domain.StreakType.consistentIntervals:
        return 'consistent_intervals';
      case domain.StreakType.noSkip:
        return 'no_skip';
    }
  }
}
