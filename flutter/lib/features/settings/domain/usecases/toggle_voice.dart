import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ToggleVoiceUseCase {
  final SettingsRepository repository;

  ToggleVoiceUseCase(this.repository);

  Future<Either<Failure, void>> call(bool isEnabled) async {
    return await repository.setVoiceEnabled(isEnabled);
  }
}
