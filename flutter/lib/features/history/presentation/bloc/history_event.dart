import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_event.freezed.dart';

@freezed
class HistoryEvent with _$HistoryEvent {
  const factory HistoryEvent.loadHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) = LoadHistory;
  
  const factory HistoryEvent.refreshHistory() = RefreshHistory;
}
