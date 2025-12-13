import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ToggleAutoCategorizeUseCase {
  final SettingsRepository repository;

  ToggleAutoCategorizeUseCase(this.repository);

  Future<Either<Failure, void>> call(bool isEnabled) async {
    return await repository.setAutoCategorize(isEnabled);
  }
}
