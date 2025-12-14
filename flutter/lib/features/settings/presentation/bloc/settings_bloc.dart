import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interval/features/notifications/domain/usecases/get_next_notification_time.dart';

import '../../domain/usecases/get_app_settings.dart';
import '../../domain/usecases/update_interval_duration.dart';
import '../../domain/usecases/toggle_notifications.dart' as usecase;
import '../../domain/usecases/complete_onboarding.dart' as usecase;
import '../../domain/usecases/toggle_voice.dart';
import '../../domain/usecases/toggle_auto_categorize.dart';
import '../../domain/usecases/set_active_hours_start.dart';
import '../../domain/usecases/set_active_hours_end.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAppSettings getAppSettings;
  final UpdateIntervalDuration updateIntervalDuration;
  final usecase.ToggleNotifications toggleNotifications;
  final usecase.CompleteOnboarding completeOnboarding;
  final ToggleVoiceUseCase toggleVoice;
  final ToggleAutoCategorizeUseCase toggleAutoCategorize;
  final SetActiveHoursStart setActiveHoursStart;
  final SetActiveHoursEnd setActiveHoursEnd;
  final GetNextNotificationTime getNextNotificationTime;

  SettingsBloc({
    required this.getAppSettings,
    required this.updateIntervalDuration,
    required this.toggleNotifications,
    required this.completeOnboarding,
    required this.toggleVoice,
    required this.toggleAutoCategorize,
    required this.setActiveHoursStart,
    required this.setActiveHoursEnd,
    required this.getNextNotificationTime,
  }) : super(const SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateInterval>(_onUpdateInterval);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleVoice>(_onToggleVoice);
    on<ToggleAutoCategorize>(_onToggleAutoCategorize);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<UpdateActiveHoursStart>(_onUpdateActiveHoursStart);
    on<UpdateActiveHoursEnd>(_onUpdateActiveHoursEnd);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await getAppSettings();

    await result.fold(
      (failure) async => emit(SettingsState.error(failure.message)),
      (settings) async {
        DateTime? nextTime;
        if (settings.notificationsEnabled) {
          final nextResult = await getNextNotificationTime(
            settings.intervalDuration,
            settings.activeHoursStart,
            settings.activeHoursEnd,
          );
          nextResult.fold(
            (_) => nextTime = null,
            (time) => nextTime = time,
          );
        }

        emit(SettingsState.loaded(settings, nextNotificationTime: nextTime));
      },
    );
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

  Future<void> _onUpdateActiveHoursStart(
    UpdateActiveHoursStart event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await setActiveHoursStart(event.hour);
    await result.fold(
      (failure) async => emit(SettingsState.error(failure.message)),
      (_) async => add(const LoadSettings()),
    );
  }

  Future<void> _onUpdateActiveHoursEnd(
    UpdateActiveHoursEnd event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    final result = await setActiveHoursEnd(event.hour);
    await result.fold(
      (failure) async => emit(SettingsState.error(failure.message)),
      (_) async => add(const LoadSettings()),
    );
  }
}
