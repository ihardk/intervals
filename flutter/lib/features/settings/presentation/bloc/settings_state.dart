import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/app_settings.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = SettingsInitial;
  const factory SettingsState.loading() = SettingsLoading;
  const factory SettingsState.loaded(
    AppSettings settings, {
    DateTime? nextNotificationTime,
  }) = SettingsLoaded;
  const factory SettingsState.error(String message) = SettingsError;
}
