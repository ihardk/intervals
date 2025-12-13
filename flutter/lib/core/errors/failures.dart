import 'package:equatable/equatable.dart';

/// Base class for all failures
/// Using the Either pattern from dartz for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Database-related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.code]);
}

/// Network-related failures (for future cloud sync)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.code]);
}

/// Notification-related failures
class NotificationFailure extends Failure {
  const NotificationFailure(super.message, [super.code]);
}

/// Voice recording/transcription failures
class VoiceFailure extends Failure {
  const VoiceFailure(super.message, [super.code]);
}

/// File system failures
class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message, [super.code]);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.code]);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Generic server failure (for future use)
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// Unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.code]);
}
