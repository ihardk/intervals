import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/logging/domain/usecases/get_logs_by_date_range.dart';
import '../../../../features/logging/domain/usecases/search_logs.dart';
import '../../../../features/logging/domain/entities/log.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetLogsByDateRange getLogsByDateRange;
  final SearchLogs searchLogs;

  HistoryBloc({
    required this.getLogsByDateRange,
    required this.searchLogs,
  }) : super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<RefreshHistory>(_onRefreshHistory);
    on<SearchHistory>(_onSearchHistory);
    on<FilterHistory>(_onFilterHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryState.loading());
    await _fetchLogs(event.startDate, event.endDate, null, null, emit);
  }

  Future<void> _onRefreshHistory(
    RefreshHistory event,
    Emitter<HistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is HistoryLoaded) {
      // Don't emit loading for refresh to keep UI stable (or use a separate loading field)
      // Standard pull-to-refresh usually manages its own loading indicator, but bloc state update is fine.
      await _fetchLogs(currentState.startDate, currentState.endDate,
          currentState.searchQuery, currentState.filterCategory, emit);
    }
  }

  Future<void> _onSearchHistory(
    SearchHistory event,
    Emitter<HistoryState> emit,
  ) async {
    // If query is empty, reload range. Else search.
    final currentState = state;
    final startDate =
        currentState is HistoryLoaded ? currentState.startDate : DateTime.now();
    final endDate =
        currentState is HistoryLoaded ? currentState.endDate : DateTime.now();
    final category =
        currentState is HistoryLoaded ? currentState.filterCategory : null;

    if (event.query.isEmpty) {
      await _fetchLogs(startDate, endDate, null, category, emit);
    } else {
      emit(const HistoryState.loading());
      final result = await searchLogs(event.query);
      result.fold(
        (failure) => emit(HistoryState.error(failure.message)),
        (logs) =>
            _emitLoaded(emit, logs, startDate, endDate, event.query, category),
      );
    }
  }

  Future<void> _onFilterHistory(
    FilterHistory event,
    Emitter<HistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is HistoryLoaded) {
      // Since we might need to re-fetch if we were just searching,
      // or just re-filter if we have the full list?
      // Simplest approach: Re-fetch with new filter (or same params)
      // But _fetchLogs fetches by Date. Search fetches by Query.
      // If Query exists, we search. If not, we fetch by Date.
      // THEN we apply Category filter.
      await _fetchLogs(currentState.startDate, currentState.endDate,
          currentState.searchQuery, event.category, emit);
    }
  }

  Future<void> _fetchLogs(DateTime startDate, DateTime endDate, String? query,
      String? category, Emitter<HistoryState> emit) async {
    // Determine source of logs
    if (query != null && query.isNotEmpty) {
      final result = await searchLogs(query);
      result.fold(
        (failure) => emit(HistoryState.error(failure.message)),
        (logs) => _emitLoaded(emit, logs, startDate, endDate, query, category),
      );
    } else {
      final result = await getLogsByDateRange(
        startTimestamp: startDate.millisecondsSinceEpoch,
        endTimestamp: endDate.millisecondsSinceEpoch,
      );
      result.fold(
        (failure) => emit(HistoryState.error(failure.message)),
        (logs) => _emitLoaded(emit, logs, startDate, endDate, null, category),
      );
    }
  }

  void _emitLoaded(
    Emitter<HistoryState> emit,
    List<Log> logs,
    DateTime startDate,
    DateTime endDate,
    String? query,
    String? category,
  ) {
    var filteredLogs = logs;
    if (category != null) {
      filteredLogs = logs.where((log) => log.category == category).toList();
    }
    emit(HistoryState.loaded(
      logs: filteredLogs,
      startDate: startDate,
      endDate: endDate,
      searchQuery: query,
      filterCategory: category,
    ));
  }
}
