import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';

import 'package:interval/features/notifications/domain/usecases/cancel_all_notifications.dart';
import 'package:interval/features/notifications/domain/usecases/get_pending_notifications.dart';
import 'package:interval/features/notifications/domain/usecases/initialize_notifications.dart';
import 'package:interval/features/notifications/domain/usecases/request_notification_permissions.dart';
import 'package:interval/features/notifications/domain/usecases/schedule_interval_notification.dart';
import 'package:interval/features/notifications/domain/usecases/schedule_recurring_notifications.dart';
import 'package:interval/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:interval/features/notifications/presentation/bloc/notification_event.dart';
import 'package:interval/features/notifications/presentation/bloc/notification_state.dart';
import 'package:interval/features/settings/domain/usecases/get_app_settings.dart';
import 'package:interval/features/settings/domain/entities/app_settings.dart';

@GenerateMocks([
  InitializeNotifications,
  RequestNotificationPermissions,
  ScheduleIntervalNotification,
  ScheduleRecurringNotifications,
  CancelAllNotifications,
  GetPendingNotifications,
  GetAppSettings,
])
import 'notification_bloc_test.mocks.dart';

void main() {
  late NotificationBloc bloc;
  late MockInitializeNotifications mockInitializeNotifications;
  late MockRequestNotificationPermissions mockRequestPermissions;
  late MockScheduleIntervalNotification mockScheduleNotification;
  late MockScheduleRecurringNotifications mockScheduleRecurring;
  late MockCancelAllNotifications mockCancelAll;
  late MockGetPendingNotifications mockGetPendingNotifications;
  late MockGetAppSettings mockGetAppSettings;

  const tAppSettings = AppSettings(
    intervalDuration: 900000,
    notificationsEnabled: true,
    voiceEnabled: false,
    dailyReminderTime: '20:00',
    autoCategorize: true,
    onboardingCompleted: true,
    activeHoursStart: 9,
    activeHoursEnd: 21,
  );

  setUp(() {
    mockInitializeNotifications = MockInitializeNotifications();
    mockRequestPermissions = MockRequestNotificationPermissions();
    mockScheduleNotification = MockScheduleIntervalNotification();
    mockScheduleRecurring = MockScheduleRecurringNotifications();
    mockCancelAll = MockCancelAllNotifications();
    mockGetPendingNotifications = MockGetPendingNotifications();
    mockGetAppSettings = MockGetAppSettings();

    // Stub getAppSettings to return default settings
    when(mockGetAppSettings())
        .thenAnswer((_) async => const Right(tAppSettings));

    bloc = NotificationBloc(
      initializeNotifications: mockInitializeNotifications,
      requestPermissions: mockRequestPermissions,
      scheduleNotification: mockScheduleNotification,
      scheduleRecurring: mockScheduleRecurring,
      cancelAll: mockCancelAll,
      getPendingNotifications: mockGetPendingNotifications,
      getAppSettings: mockGetAppSettings,
    );
  });

  test('initial state is NotificationInitial', () {
    expect(bloc.state, const NotificationState.initial());
  });

  group('InitializeNotifications', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [loading, initialized] when initialization succeeds',
      build: () {
        when(mockInitializeNotifications())
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.initialize()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.initialized(),
      ],
      verify: (_) {
        verify(mockInitializeNotifications());
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [loading, error] when initialization fails',
      build: () {
        when(mockInitializeNotifications()).thenAnswer(
          (_) async => const Left(NotificationFailure('Init failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.initialize()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.error('Init failed'),
      ],
    );
  });

  group('RequestPermissions', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [loading, permissionsUpdated] when permissions granted',
      build: () {
        when(mockRequestPermissions())
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.requestPermissions()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.permissionsUpdated(true),
      ],
      verify: (_) {
        verify(mockRequestPermissions());
      },
    );
  });
}
