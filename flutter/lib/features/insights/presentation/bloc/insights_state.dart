import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/insight.dart';

part 'insights_state.freezed.dart';

@freezed
class InsightsState with _$InsightsState {
  const factory InsightsState.initial() = InsightsInitial;
  const factory InsightsState.loading() = InsightsLoading;
  const factory InsightsState.loaded({
    required Insight dailyInsight,
    required List<ActivityCount> topActivities,
    required double completionRate,
  }) = InsightsLoaded;
  const factory InsightsState.error(String message) = InsightsError;
}
