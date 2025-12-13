import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Use case for getting app settings
class GetAppSettings {
  final SettingsRepository repository;

  GetAppSettings(this.repository);

  Future<Either<Failure, AppSettings>> call() {
    return repository.getAppSettings();
  }
}
