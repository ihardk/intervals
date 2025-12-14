import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/settings_repository.dart';

class SetActiveHoursStart {
  final SettingsRepository repository;

  SetActiveHoursStart(this.repository);

  Future<Either<Failure, void>> call(int hour) {
    return repository.setActiveHoursStart(hour);
  }
}
