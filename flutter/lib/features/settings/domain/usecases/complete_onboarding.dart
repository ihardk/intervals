import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

/// Use case for marking onboarding as completed
class CompleteOnboarding {
  final SettingsRepository repository;

  CompleteOnboarding(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.setOnboardingCompleted(true);
  }
}
