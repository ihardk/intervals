import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_state.freezed.dart';

@freezed
class VoiceState with _$VoiceState {
  const factory VoiceState.initial() = _Initial;
  const factory VoiceState.listening({required String partialResult}) =
      _Listening;
  const factory VoiceState.success(String text) = _Success;
  const factory VoiceState.failure(String message) = _Failure;
}
