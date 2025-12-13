import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/logging/domain/usecases/get_logs_by_date_range.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetLogsByDateRange getLogsByDateRange;

  HistoryBloc({
    required this.getLogsByDateRange,
  }) : super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<RefreshHistory>(_onRefreshHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryState.loading());

    final result = await getLogsByDateRange(
      startTimestamp: event.startDate.millisecondsSinceEpoch,
      endTimestamp: event.endDate.millisecondsSinceEpoch,
    );

    result.fold(
      (failure) => emit(HistoryState.error(failure.message)),
      (logs) => emit(HistoryState.loaded(logs)),
    );
  }

  Future<void> _onRefreshHistory(
    RefreshHistory event,
    Emitter<HistoryState> emit,
  ) async {
    // TODO: Implement refresh history
  }
}
