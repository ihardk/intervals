import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/settings_repository.dart';

class SetActiveHoursEnd {
  final SettingsRepository repository;

  SetActiveHoursEnd(this.repository);

  Future<Either<Failure, void>> call(int hour) {
    return repository.setActiveHoursEnd(hour);
  }
}
