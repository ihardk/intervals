import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/notifications/domain/entities/scheduled_notification.dart';
import 'package:interval/features/notifications/domain/repositories/notification_repository.dart';
import 'package:interval/features/notifications/domain/usecases/schedule_interval_notification.dart';

@GenerateMocks([NotificationRepository])
import 'schedule_interval_notification_test.mocks.dart';

void main() {
  late ScheduleIntervalNotification usecase;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    usecase = ScheduleIntervalNotification(mockNotificationRepository);
  });

  final tScheduledTime = DateTime.now()
      .add(const Duration(minutes: 15))
      .millisecondsSinceEpoch;

  final tInput = ScheduleNotificationInput(
    id: 1,
    scheduledTime: tScheduledTime,
    title: 'What are you doing?',
    body: 'Tap to log your activity',
    intervalDuration: 900000, // 15 minutes
  );

  group('ScheduleIntervalNotification', () {
    test(
      'should schedule notification successfully',
      () async {
        // Arrange
        when(mockNotificationRepository.scheduleIntervalNotification(any))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await usecase(tInput);

        // Assert
        expect(result, const Right(null));
        verify(mockNotificationRepository.scheduleIntervalNotification(tInput));
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );

    test(
      'should return failure when scheduling fails',
      () async {
        // Arrange
        final tFailure = NotificationFailure('Failed to schedule notification');
        when(mockNotificationRepository.scheduleIntervalNotification(any))
            .thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase(tInput);

        // Assert
        expect(result, Left(tFailure));
        verify(mockNotificationRepository.scheduleIntervalNotification(tInput));
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );
  });
}
