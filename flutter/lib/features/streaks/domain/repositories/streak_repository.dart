import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/streak.dart';

/// Repository interface for Streak operations
/// Manages user consistency and streak tracking
abstract class StreakRepository {
  /// Get a streak by ID
  Future<Either<Failure, Streak>> getStreakById(String id);

  /// Get current active streak by type
  Future<Either<Failure, Streak?>> getActiveStreak(String streakType);

  /// Get all active streaks
  Future<Either<Failure, List<Streak>>> getActiveStreaks();

  /// Get all streaks by type
  Future<Either<Failure, List<Streak>>> getStreaksByType(String streakType);

  /// Get best streak count by type
  Future<Either<Failure, int>> getBestStreakCount(String streakType);

  /// Get current streak count by type
  Future<Either<Failure, int>> getCurrentStreakCount(String streakType);

  /// Check if a streak is active
  Future<Either<Failure, bool>> isStreakActive(String streakType);

  /// Create a new streak
  Future<Either<Failure, Streak>> createStreak({
    required String streakType,
    required String startDate,
    int currentCount = 1,
    int bestCount = 1,
  });

  /// Update a streak
  Future<Either<Failure, void>> updateStreak(Streak streak);

  /// Increment a streak count
  Future<Either<Failure, void>> incrementStreak(String id);

  /// Break a streak (set inactive)
  Future<Either<Failure, void>> breakStreak(String id);

  /// Reset current count to 0
  Future<Either<Failure, void>> resetCurrentCount(String id);

  /// Delete a streak
  Future<Either<Failure, void>> deleteStreak(String id);

  /// Delete all streaks by type
  Future<Either<Failure, int>> deleteStreaksByType(String streakType);

  /// Get all streaks
  Future<Either<Failure, List<Streak>>> getAllStreaks();

  /// Watch active streak by type (reactive stream)
  Stream<Either<Failure, Streak?>> watchActiveStreak(String streakType);

  /// Watch all active streaks (reactive stream)
  Stream<Either<Failure, List<Streak>>> watchActiveStreaks();
}
