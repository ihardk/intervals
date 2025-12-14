import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_event.freezed.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.loadSettings() = LoadSettings;
  const factory SettingsEvent.updateInterval(int durationMs) = UpdateInterval;
  const factory SettingsEvent.toggleNotifications(bool enabled) =
      ToggleNotifications;
  const factory SettingsEvent.toggleVoice(bool enabled) = ToggleVoice;
  const factory SettingsEvent.toggleAutoCategorize(bool enabled) =
      ToggleAutoCategorize;
  const factory SettingsEvent.completeOnboarding() = CompleteOnboarding;
  const factory SettingsEvent.updateActiveHoursStart(int hour) =
      UpdateActiveHoursStart;
  const factory SettingsEvent.updateActiveHoursEnd(int hour) =
      UpdateActiveHoursEnd;
}
