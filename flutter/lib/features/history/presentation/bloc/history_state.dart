import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval/features/logging/domain/entities/log.dart';

part 'history_state.freezed.dart';

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = HistoryInitial;
  const factory HistoryState.loading() = HistoryLoading;
  const factory HistoryState.loaded({
    required List<Log> logs,
    required DateTime startDate,
    required DateTime endDate,
    String? searchQuery,
    String? filterCategory,
  }) = HistoryLoaded;
  const factory HistoryState.error(String message) = HistoryError;
}
