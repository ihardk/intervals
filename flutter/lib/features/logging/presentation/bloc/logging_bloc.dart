import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_log.dart';
import '../../domain/usecases/delete_log.dart';
import '../../domain/usecases/get_today_logs.dart';
import '../../domain/usecases/search_logs.dart';
import '../../domain/usecases/update_log.dart';
import '../../../notifications/domain/usecases/cancel_all_notifications.dart';
import '../../../notifications/domain/usecases/schedule_recurring_notifications.dart';
import '../../../settings/domain/usecases/get_app_settings.dart';
import 'logging_event.dart';
import 'logging_state.dart';

/// Bloc for managing logging feature state
/// Handles all business logic for creating, reading, updating, deleting logs
/// UI should remain clean - all logic here
class LoggingBloc extends Bloc<LoggingEvent, LoggingState> {
  final CreateLog createLog;
  final GetTodayLogs getTodayLogs;
  final UpdateLog updateLog;
  final DeleteLog deleteLog;
  final SearchLogs searchLogs;
  final CancelAllNotifications cancelAllNotifications;
  final ScheduleRecurringNotifications scheduleRecurringNotifications;
  final GetAppSettings getAppSettings;

  LoggingBloc({
    required this.createLog,
    required this.getTodayLogs,
    required this.updateLog,
    required this.deleteLog,
    required this.searchLogs,
    required this.cancelAllNotifications,
    required this.scheduleRecurringNotifications,
    required this.getAppSettings,
  }) : super(const LoggingState.initial()) {
    on<LoadTodayLogsEvent>(_onLoadTodayLogs);
    on<CreateLogEvent>(_onCreateLog);
    on<UpdateLogEvent>(_onUpdateLog);
    on<DeleteLogEvent>(_onDeleteLog);
    on<SearchLogsEvent>(_onSearchLogs);
    on<ClearSearchEvent>(_onClearSearch);
    on<RefreshLogsEvent>(_onRefresh);
  }

  /// Load today's logs
  Future<void> _onLoadTodayLogs(
    LoadTodayLogsEvent event,
    Emitter<LoggingState> emit,
  ) async {
    emit(const LoggingState.loading());

    final result = await getTodayLogs();

    result.fold(
      (failure) => emit(LoggingState.error(message: failure.message)),
      (logs) => emit(LoggingState.loaded(logs: logs)),
    );
  }

  /// Create a new log
  Future<void> _onCreateLog(
    CreateLogEvent event,
    Emitter<LoggingState> emit,
  ) async {
    emit(const LoggingState.loading());

    final result = await createLog(
      content: event.content,
      entryType: event.entryType,
      audioPath: event.audioPath,
      category: event.category,
      tags: event.tags,
      mood: event.mood,
    );

    await result.fold(
      (failure) async => emit(LoggingState.error(message: failure.message)),
      (log) async {
        // Cancel all pending notifications and reschedule
        await _rescheduleNotifications();

        // Reload today's logs to get updated list
        final logsResult = await getTodayLogs();
        logsResult.fold(
          (failure) => emit(LoggingState.error(message: failure.message)),
          (logs) => emit(LoggingState.success(
            message: 'Log created successfully',
            logs: logs,
          )),
        );
      },
    );
  }

  /// Helper to cancel and reschedule all notifications
  Future<void> _rescheduleNotifications() async {
    try {
      // Cancel all pending notifications
      await cancelAllNotifications();

      // Get current settings for interval duration and active hours
      final settingsResult = await getAppSettings();
      await settingsResult.fold(
        (failure) async {
          print('LoggingBloc: Failed to get settings for rescheduling: ${failure.message}');
        },
        (settings) async {
          // Schedule next batch of notifications
          await scheduleRecurringNotifications(
            settings.intervalDuration,
            50, // Schedule 50 notifications ahead (~12.5 hours for 15min intervals)
            startHour: settings.activeHoursStart,
            endHour: settings.activeHoursEnd,
          );
          print('LoggingBloc: Rescheduled notifications after log creation');
        },
      );
    } catch (e) {
      print('LoggingBloc: Error rescheduling notifications: $e');
    }
  }

  /// Update an existing log
  Future<void> _onUpdateLog(
    UpdateLogEvent event,
    Emitter<LoggingState> emit,
  ) async {
    emit(const LoggingState.loading());

    final result = await updateLog(event.log);

    await result.fold(
      (failure) async => emit(LoggingState.error(message: failure.message)),
      (_) async {
        // Reload today's logs to get updated list
        final logsResult = await getTodayLogs();
        logsResult.fold(
          (failure) => emit(LoggingState.error(message: failure.message)),
          (logs) => emit(LoggingState.success(
            message: 'Log updated successfully',
            logs: logs,
          )),
        );
      },
    );
  }

  /// Delete a log (soft delete)
  Future<void> _onDeleteLog(
    DeleteLogEvent event,
    Emitter<LoggingState> emit,
  ) async {
    emit(const LoggingState.loading());

    final result = await deleteLog(event.id);

    await result.fold(
      (failure) async => emit(LoggingState.error(message: failure.message)),
      (_) async {
        // Reload today's logs to get updated list
        final logsResult = await getTodayLogs();
        logsResult.fold(
          (failure) => emit(LoggingState.error(message: failure.message)),
          (logs) => emit(LoggingState.success(
            message: 'Log deleted successfully',
            logs: logs,
          )),
        );
      },
    );
  }

  /// Search logs by query
  Future<void> _onSearchLogs(
    SearchLogsEvent event,
    Emitter<LoggingState> emit,
  ) async {
    emit(const LoggingState.loading());

    final result = await searchLogs(event.query);

    result.fold(
      (failure) => emit(LoggingState.error(message: failure.message)),
      (logs) => emit(LoggingState.loaded(
        logs: logs,
        isSearching: true,
        searchQuery: event.query,
      )),
    );
  }

  /// Clear search and return to today's logs
  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<LoggingState> emit,
  ) async {
    emit(const LoggingState.loading());

    final result = await getTodayLogs();

    result.fold(
      (failure) => emit(LoggingState.error(message: failure.message)),
      (logs) => emit(LoggingState.loaded(logs: logs)),
    );
  }

  /// Refresh today's logs
  Future<void> _onRefresh(
    RefreshLogsEvent event,
    Emitter<LoggingState> emit,
  ) async {
    // Don't show loading state for refresh (pull-to-refresh UX)
    final result = await getTodayLogs();

    result.fold(
      (failure) => emit(LoggingState.error(message: failure.message)),
      (logs) => emit(LoggingState.loaded(logs: logs)),
    );
  }
}
