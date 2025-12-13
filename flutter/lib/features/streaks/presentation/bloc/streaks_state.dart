import 'package:freezed_annotation/freezed_annotation.dart';

part 'streaks_state.freezed.dart';

@freezed
class StreaksState with _$StreaksState {
  const factory StreaksState.initial() = StreaksInitial;
  const factory StreaksState.loading() = StreaksLoading;
  const factory StreaksState.loaded(int count) = StreaksLoaded;
  const factory StreaksState.error(String message) = StreaksError;
}
