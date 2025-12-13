import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/streak.dart';
import '../repositories/streak_repository.dart';

class UpdateStreak {
  final StreakRepository repository;

  UpdateStreak(this.repository);

  Future<Either<Failure, void>> call(Streak streak) {
    return repository.updateStreak(streak);
  }
}
