import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

/// Use case for updating interval duration
class UpdateIntervalDuration {
  final SettingsRepository repository;

  UpdateIntervalDuration(this.repository);

  Future<Either<Failure, void>> call(int durationMs) {
    return repository.setIntervalDuration(durationMs);
  }
}
