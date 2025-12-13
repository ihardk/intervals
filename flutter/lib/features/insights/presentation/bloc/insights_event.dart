import 'package:freezed_annotation/freezed_annotation.dart';

part 'insights_event.freezed.dart';

@freezed
class InsightsEvent with _$InsightsEvent {
  const factory InsightsEvent.loadInsights([DateTime? date]) = LoadInsights;
  const factory InsightsEvent.refreshInsights() = RefreshInsights;
}
