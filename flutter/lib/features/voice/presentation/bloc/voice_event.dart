import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_event.freezed.dart';

@freezed
class VoiceEvent with _$VoiceEvent {
  const factory VoiceEvent.initialize() = Initialize;
  const factory VoiceEvent.startListening() = StartListening;
  const factory VoiceEvent.stopListening() = StopListening;
  const factory VoiceEvent.processResult(String text) = ProcessResult;
}
