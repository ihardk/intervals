import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/notifications/domain/entities/scheduled_notification.dart';
import 'package:interval/features/notifications/domain/usecases/cancel_all_notifications.dart';
import 'package:interval/features/notifications/domain/usecases/get_pending_notifications.dart';
import 'package:interval/features/notifications/domain/usecases/initialize_notifications.dart';
import 'package:interval/features/notifications/domain/usecases/request_notification_permissions.dart';
import 'package:interval/features/notifications/domain/usecases/schedule_interval_notification.dart';
import 'package:interval/features/notifications/domain/usecases/schedule_recurring_notifications.dart';
import 'package:interval/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:interval/features/notifications/presentation/bloc/notification_event.dart';
import 'package:interval/features/notifications/presentation/bloc/notification_state.dart';

@GenerateMocks([
  InitializeNotifications,
  RequestNotificationPermissions,
  ScheduleIntervalNotification,
  ScheduleRecurringNotifications,
  CancelAllNotifications,
  GetPendingNotifications,
])
import 'notification_bloc_test.mocks.dart';

void main() {
  late NotificationBloc bloc;
  late MockInitializeNotifications mockInitialize;
  late MockRequestNotificationPermissions mockRequestPermissions;
  late MockScheduleIntervalNotification mockScheduleNotification;
  late MockScheduleRecurringNotifications mockScheduleRecurring;
  late MockCancelAllNotifications mockCancelAll;
  late MockGetPendingNotifications mockGetPending;

  setUp(() {
    mockInitialize = MockInitializeNotifications();
    mockRequestPermissions = MockRequestNotificationPermissions();
    mockScheduleNotification = MockScheduleIntervalNotification();
    mockScheduleRecurring = MockScheduleRecurringNotifications();
    mockCancelAll = MockCancelAllNotifications();
    mockGetPending = MockGetPendingNotifications();

    bloc = NotificationBloc(
      initializeNotifications: mockInitialize,
      requestPermissions: mockRequestPermissions,
      scheduleNotification: mockScheduleNotification,
      scheduleRecurring: mockScheduleRecurring,
      cancelAll: mockCancelAll,
      getPendingNotifications: mockGetPending,
    );
  });

  test('initial state is NotificationInitial', () {
    expect(bloc.state, const NotificationState.initial());
  });

  group('InitializeNotifications', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationInitialized] when initialization succeeds',
      build: () {
        when(mockInitialize()).thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.initialize()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.initialized(
          permissionsGranted: true,
          notificationsEnabled: true,
        ),
      ],
      verify: (_) {
        verify(mockInitialize());
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] when initialization fails',
      build: () {
        when(mockInitialize()).thenAnswer(
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
      'emits [NotificationLoading, NotificationInitialized] when permissions granted',
      build: () {
        when(mockRequestPermissions())
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.requestPermissions()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.initialized(
          permissionsGranted: true,
          notificationsEnabled: true,
        ),
      ],
      verify: (_) {
        verify(mockRequestPermissions());
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationPermissionDenied] when permissions denied',
      build: () {
        when(mockRequestPermissions())
            .thenAnswer((_) async => const Right(false));
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.requestPermissions()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.initialized(
          permissionsGranted: false,
          notificationsEnabled: false,
        ),
      ],
    );
  });

  group('ScheduleNotification', () {
    final tScheduledTime = DateTime.now()
        .add(const Duration(minutes: 15))
        .millisecondsSinceEpoch;

    final tInput = ScheduleNotificationInput(
      id: 1,
      scheduledTime: tScheduledTime,
      title: 'What are you doing?',
      body: 'Tap to log your activity',
      intervalDuration: 900000,
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationScheduled] when scheduling succeeds',
      build: () {
        when(mockScheduleNotification(any))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(NotificationEvent.scheduleNotification(tInput)),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.scheduled(),
      ],
      verify: (_) {
        verify(mockScheduleNotification(tInput));
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] when scheduling fails',
      build: () {
        when(mockScheduleNotification(any)).thenAnswer(
          (_) async => const Left(NotificationFailure('Schedule failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(NotificationEvent.scheduleNotification(tInput)),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.error('Schedule failed'),
      ],
    );
  });

  group('ScheduleRecurring', () {
    const tIntervalDuration = 900000; // 15 minutes
    const tCount = 24; // 24 notifications

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationScheduled] when scheduling recurring succeeds',
      build: () {
        when(mockScheduleRecurring(any, any))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.scheduleRecurring(
        intervalDuration: tIntervalDuration,
        count: tCount,
      )),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.scheduled(),
      ],
      verify: (_) {
        verify(mockScheduleRecurring(tIntervalDuration, tCount));
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] when scheduling recurring fails',
      build: () {
        when(mockScheduleRecurring(any, any)).thenAnswer(
          (_) async => const Left(NotificationFailure('Recurring failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.scheduleRecurring(
        intervalDuration: tIntervalDuration,
        count: tCount,
      )),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.error('Recurring failed'),
      ],
    );
  });

  group('CancelAll', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationCancelled] when cancelling succeeds',
      build: () {
        when(mockCancelAll()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.cancelAll()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.cancelled(),
      ],
      verify: (_) {
        verify(mockCancelAll());
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] when cancelling fails',
      build: () {
        when(mockCancelAll()).thenAnswer(
          (_) async => const Left(NotificationFailure('Cancel failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationEvent.cancelAll()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.error('Cancel failed'),
      ],
    );
  });

  group('LoadPendingNotifications', () {
    final tNotifications = [
      ScheduledNotification(
        id: 1,
        scheduledTime: DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch,
        title: 'What are you doing?',
        body: 'Tap to log',
        intervalDuration: 900000,
      ),
      ScheduledNotification(
        id: 2,
        scheduledTime: DateTime.now().add(const Duration(minutes: 30)).millisecondsSinceEpoch,
        title: 'What are you doing?',
        body: 'Tap to log',
        intervalDuration: 900000,
      ),
    ];

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationPending] when loading succeeds',
      build: () {
        when(mockGetPending())
            .thenAnswer((_) async => Right(tNotifications));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const NotificationEvent.loadPendingNotifications()),
      expect: () => [
        const NotificationState.loading(),
        NotificationState.pending(tNotifications),
      ],
      verify: (_) {
        verify(mockGetPending());
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] when loading fails',
      build: () {
        when(mockGetPending()).thenAnswer(
          (_) async => const Left(NotificationFailure('Load failed')),
        );
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const NotificationEvent.loadPendingNotifications()),
      expect: () => [
        const NotificationState.loading(),
        const NotificationState.error('Load failed'),
      ],
    );
  });
}
