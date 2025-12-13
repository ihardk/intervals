/// Base class for all exceptions
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Database-related exceptions
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.code]);

  @override
  String toString() => 'DatabaseException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);

  @override
  String toString() => 'CacheException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network-related exceptions (for future use)
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);

  @override
  String toString() => 'NetworkException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Permission-related exceptions
class PermissionException extends AppException {
  final String permissionType;

  const PermissionException(super.message, this.permissionType, [super.code]);

  @override
  String toString() =>
      'PermissionException: $message (permission: $permissionType)${code != null ? ' (code: $code)' : ''}';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException(super.message, [this.errors, super.code]);

  @override
  String toString() =>
      'ValidationException: $message${errors != null ? ' errors: $errors' : ''}${code != null ? ' (code: $code)' : ''}';
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);

  @override
  String toString() => 'NotFoundException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Server exceptions (for future use)
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(super.message, [this.statusCode, super.code]);

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (status: $statusCode)' : ''}${code != null ? ' (code: $code)' : ''}';
}
