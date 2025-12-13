import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/log.dart';

part 'logging_state.freezed.dart';

/// States for LoggingBloc
/// Represents the current state of the logging feature
@freezed
class LoggingState with _$LoggingState {
  /// Initial state - no data loaded yet
  const factory LoggingState.initial() = LoggingInitial;

  /// Loading state - fetching data
  const factory LoggingState.loading() = LoggingLoading;

  /// Loaded state - data successfully retrieved
  const factory LoggingState.loaded({
    required List<Log> logs,
    @Default(false) bool isSearching,
    String? searchQuery,
  }) = LoggingLoaded;

  /// Error state - operation failed
  const factory LoggingState.error({
    required String message,
  }) = LoggingError;

  /// Success state - operation completed (create/update/delete)
  const factory LoggingState.success({
    required String message,
    required List<Log> logs,
  }) = LoggingSuccess;
}
