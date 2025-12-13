import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/streak_repository.dart';

class GetCurrentStreak {
  final StreakRepository repository;

  GetCurrentStreak(this.repository);

  Future<Either<Failure, int>> call(String streakType) {
    return repository.getCurrentStreakCount(streakType);
  }
}
