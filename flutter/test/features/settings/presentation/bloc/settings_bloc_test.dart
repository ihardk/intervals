import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/settings/domain/entities/app_settings.dart';
import 'package:interval/features/settings/domain/usecases/get_app_settings.dart';
import 'package:interval/features/settings/domain/usecases/update_interval_duration.dart';
import 'package:interval/features/settings/domain/usecases/toggle_notifications.dart'
    as usecase;
import 'package:interval/features/settings/domain/usecases/complete_onboarding.dart'
    as usecase;
import 'package:interval/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:interval/features/settings/presentation/bloc/settings_event.dart';
import 'package:interval/features/settings/presentation/bloc/settings_state.dart';

import 'package:interval/features/settings/domain/usecases/toggle_voice.dart';
import 'package:interval/features/settings/domain/usecases/toggle_auto_categorize.dart';
import 'package:interval/features/settings/domain/usecases/set_active_hours_start.dart';
import 'package:interval/features/settings/domain/usecases/set_active_hours_end.dart';
import 'package:interval/features/notifications/domain/usecases/get_next_notification_time.dart';

@GenerateMocks([
  GetAppSettings,
  UpdateIntervalDuration,
  usecase.ToggleNotifications,
  usecase.CompleteOnboarding,
  ToggleVoiceUseCase,
  ToggleAutoCategorizeUseCase,
  SetActiveHoursStart,
  SetActiveHoursEnd,
  GetNextNotificationTime,
])
import 'settings_bloc_test.mocks.dart';

void main() {
  late SettingsBloc bloc;
  late MockGetAppSettings mockGetAppSettings;
  late MockUpdateIntervalDuration mockUpdateIntervalDuration;
  late MockToggleNotifications mockToggleNotifications;
  late MockCompleteOnboarding mockCompleteOnboarding;
  late MockToggleVoiceUseCase mockToggleVoiceUseCase;
  late MockToggleAutoCategorizeUseCase mockToggleAutoCategorizeUseCase;

  late MockSetActiveHoursStart mockSetActiveHoursStart;
  late MockSetActiveHoursEnd mockSetActiveHoursEnd;

  late MockGetNextNotificationTime mockGetNextNotificationTime;

  setUp(() {
    mockGetAppSettings = MockGetAppSettings();
    mockUpdateIntervalDuration = MockUpdateIntervalDuration();
    mockToggleNotifications = MockToggleNotifications();
    mockCompleteOnboarding = MockCompleteOnboarding();
    mockToggleVoiceUseCase = MockToggleVoiceUseCase();
    mockToggleAutoCategorizeUseCase = MockToggleAutoCategorizeUseCase();
    mockSetActiveHoursStart = MockSetActiveHoursStart();
    mockSetActiveHoursEnd = MockSetActiveHoursEnd();
    mockGetNextNotificationTime = MockGetNextNotificationTime();

    bloc = SettingsBloc(
      getAppSettings: mockGetAppSettings,
      updateIntervalDuration: mockUpdateIntervalDuration,
      toggleNotifications: mockToggleNotifications,
      completeOnboarding: mockCompleteOnboarding,
      toggleVoice: mockToggleVoiceUseCase,
      toggleAutoCategorize: mockToggleAutoCategorizeUseCase,
      setActiveHoursStart: mockSetActiveHoursStart,
      setActiveHoursEnd: mockSetActiveHoursEnd,
      getNextNotificationTime: mockGetNextNotificationTime,
    );

    // Default stub
    when(mockGetNextNotificationTime(any, any, any))
        .thenAnswer((_) async => const Right(null));
  });

  const tAppSettings = AppSettings(
    intervalDuration: 900000,
    notificationsEnabled: true,
  );

  test('initial state is SettingsInitial', () {
    expect(bloc.state, const SettingsState.initial());
  });

  blocTest<SettingsBloc, SettingsState>(
    'emits [SettingsLoading, SettingsLoaded] when LoadSettings is added and success',
    build: () {
      when(mockGetAppSettings())
          .thenAnswer((_) async => const Right(tAppSettings));
      return bloc;
    },
    act: (bloc) => bloc.add(const SettingsEvent.loadSettings()),
    expect: () => [
      const SettingsState.loading(),
      const SettingsState.loaded(tAppSettings),
    ],
    verify: (_) {
      verify(mockGetAppSettings());
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'emits [SettingsLoading, SettingsError] when LoadSettings fails',
    build: () {
      when(mockGetAppSettings())
          .thenAnswer((_) async => const Left(CacheFailure('Error')));
      return bloc;
    },
    act: (bloc) => bloc.add(const SettingsEvent.loadSettings()),
    expect: () => [
      const SettingsState.loading(),
      const SettingsState.error('Error'),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'emits [SettingsLoading, SettingsLoaded] when UpdateInterval is added and success',
    build: () {
      when(mockUpdateIntervalDuration(any))
          .thenAnswer((_) async => const Right(null));
      when(mockGetAppSettings())
          .thenAnswer((_) async => const Right(tAppSettings));
      return bloc;
    },
    act: (bloc) => bloc.add(const SettingsEvent.updateInterval(900000)),
    expect: () => [
      const SettingsState.loading(),
      const SettingsState.loaded(tAppSettings),
    ],
    verify: (_) {
      verify(mockUpdateIntervalDuration(900000));
      verify(mockGetAppSettings());
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'emits [SettingsLoading, SettingsLoaded] when ToggleNotifications is added and success',
    build: () {
      when(mockToggleNotifications(any))
          .thenAnswer((_) async => const Right(null));
      when(mockGetAppSettings())
          .thenAnswer((_) async => const Right(tAppSettings));
      return bloc;
    },
    act: (bloc) => bloc.add(const SettingsEvent.toggleNotifications(true)),
    expect: () => [
      const SettingsState.loading(),
      const SettingsState.loaded(tAppSettings),
    ],
    verify: (_) {
      verify(mockToggleNotifications(true));
      verify(mockGetAppSettings());
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'emits [SettingsLoading, SettingsLoaded] when CompleteOnboarding is added and success',
    build: () {
      when(mockCompleteOnboarding()).thenAnswer((_) async => const Right(null));
      when(mockGetAppSettings())
          .thenAnswer((_) async => const Right(tAppSettings));
      return bloc;
    },
    act: (bloc) => bloc.add(const SettingsEvent.completeOnboarding()),
    expect: () => [
      const SettingsState.loading(),
      const SettingsState.loaded(tAppSettings),
    ],
    verify: (_) {
      verify(mockCompleteOnboarding());
      verify(mockGetAppSettings());
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'emits [SettingsLoading, SettingsLoaded] when UpdateActiveHoursStart is added and success',
    build: () {
      when(mockSetActiveHoursStart(any))
          .thenAnswer((_) async => const Right(null));
      when(mockGetAppSettings())
          .thenAnswer((_) async => const Right(tAppSettings));
      return bloc;
    },
    act: (bloc) => bloc.add(const SettingsEvent.updateActiveHoursStart(9)),
    expect: () => [
      const SettingsState.loading(),
      const SettingsState.loaded(tAppSettings),
    ],
    verify: (_) {
      verify(mockSetActiveHoursStart(9));
      verify(mockGetAppSettings());
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'emits [SettingsLoading, SettingsLoaded] when UpdateActiveHoursEnd is added and success',
    build: () {
      when(mockSetActiveHoursEnd(any))
          .thenAnswer((_) async => const Right(null));
      when(mockGetAppSettings())
          .thenAnswer((_) async => const Right(tAppSettings));
      return bloc;
    },
    act: (bloc) => bloc.add(const SettingsEvent.updateActiveHoursEnd(21)),
    expect: () => [
      const SettingsState.loading(),
      const SettingsState.loaded(tAppSettings),
    ],
    verify: (_) {
      verify(mockSetActiveHoursEnd(21));
      verify(mockGetAppSettings());
    },
  );
}
