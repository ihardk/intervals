import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class VoiceRepository {
  /// Initialize the speech engine
  Future<Either<Failure, bool>> initialize();

  /// Start listening for speech
  Future<Either<Failure, void>> startListening({
    required Function(String) onResult,
  });

  /// Stop listening
  Future<Either<Failure, void>> stopListening();

  /// Check if listening is active
  bool get isListening;
}
