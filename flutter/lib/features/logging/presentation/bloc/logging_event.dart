import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/log.dart';

part 'logging_event.freezed.dart';

/// Events for LoggingBloc
/// User actions that trigger state changes
@freezed
class LoggingEvent with _$LoggingEvent {
  /// Load today's logs
  const factory LoggingEvent.loadTodayLogs() = LoadTodayLogsEvent;

  /// Create a new log
  const factory LoggingEvent.createLog({
    required String content,
    required String entryType,
    String? audioPath,
    String? category,
    List<String>? tags,
    String? mood,
  }) = CreateLogEvent;

  /// Update an existing log
  /// Pass the full updated log entity
  const factory LoggingEvent.updateLog({
    required Log log,
  }) = UpdateLogEvent;

  /// Delete a log (soft delete)
  const factory LoggingEvent.deleteLog({
    required String id,
  }) = DeleteLogEvent;

  /// Search logs by query
  const factory LoggingEvent.searchLogs({
    required String query,
  }) = SearchLogsEvent;

  /// Clear search and return to today's logs
  const factory LoggingEvent.clearSearch() = ClearSearchEvent;

  /// Refresh today's logs
  const factory LoggingEvent.refresh() = RefreshLogsEvent;
}
