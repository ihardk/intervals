import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

/// Use case for toggling notifications on/off
class ToggleNotifications {
  final SettingsRepository repository;

  ToggleNotifications(this.repository);

  Future<Either<Failure, void>> call(bool enabled) {
    return repository.setNotificationsEnabled(enabled);
  }
}
