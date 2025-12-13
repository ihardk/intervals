import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_app_settings.dart';
import '../../domain/usecases/update_interval_duration.dart';
import '../../domain/usecases/toggle_notifications.dart' as usecase;
import '../../domain/usecases/complete_onboarding.dart' as usecase;
import '../../domain/usecases/toggle_voice.dart';
import '../../domain/usecases/toggle_auto_categorize.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAppSettings getAppSettings;
  final UpdateIntervalDuration updateIntervalDuration;
  final usecase.ToggleNotifications toggleNotifications;
  final usecase.CompleteOnboarding completeOnboarding;
  final ToggleVoiceUseCase toggleVoice;
  final ToggleAutoCategorizeUseCase toggleAutoCategorize;

  SettingsBloc({
    required this.getAppSettings,
    required this.updateIntervalDuration,
    required this.toggleNotifications,
    required this.completeOnboarding,
    required this.toggleVoice,
    required this.toggleAutoCategorize,
  }) : super(const SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateInterval>(_onUpdateInterval);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleVoice>(_onToggleVoice);
    on<ToggleAutoCategorize>(_onToggleAutoCategorize);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await getAppSettings();
    emit(result.fold(
      (failure) => SettingsState.error(failure.message),
      (settings) => SettingsState.loaded(settings),
    ));
  }

  Future<void> _onUpdateInterval(
    UpdateInterval event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await updateIntervalDuration(event.durationMs);
    await result.fold(
      (failure) async => emit(SettingsState.error(failure.message)),
      (_) async => add(const LoadSettings()),
    );
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await toggleNotifications(event.enabled);
    await result.fold(
      (failure) async => emit(SettingsState.error(failure.message)),
      (_) async => add(const LoadSettings()),
    );
  }

  Future<void> _onToggleVoice(
    ToggleVoice event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await toggleVoice(event.enabled);
    await result.fold(
      (failure) async => emit(SettingsState.error(failure.message)),
      (_) async => add(const LoadSettings()),
    );
  }

  Future<void> _onToggleAutoCategorize(
    ToggleAutoCategorize event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await toggleAutoCategorize(event.enabled);
    await result.fold(
      (failure) async => emit(SettingsState.error(failure.message)),
      (_) async => add(const LoadSettings()),
    );
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await completeOnboarding();
    await result.fold(
      (failure) async => emit(SettingsState.error(failure.message)),
      (_) async => add(const LoadSettings()),
    );
  }
}
