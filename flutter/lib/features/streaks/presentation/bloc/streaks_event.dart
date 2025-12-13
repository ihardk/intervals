import 'package:freezed_annotation/freezed_annotation.dart';

part 'streaks_event.freezed.dart';

@freezed
class StreaksEvent with _$StreaksEvent {
  const factory StreaksEvent.loadStreak(String type) = LoadStreak;
}
