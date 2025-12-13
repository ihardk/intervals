import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/notifications/domain/repositories/notification_repository.dart';
import 'package:interval/features/notifications/domain/usecases/schedule_recurring_notifications.dart';

@GenerateMocks([NotificationRepository])
import 'schedule_recurring_notifications_test.mocks.dart';

void main() {
  late ScheduleRecurringNotifications usecase;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    usecase = ScheduleRecurringNotifications(mockNotificationRepository);
  });

  const tIntervalDuration = 900000; // 15 minutes
  const tCount = 24; // Schedule 24 notifications (6 hours ahead)

  group('ScheduleRecurringNotifications', () {
    test(
      'should schedule recurring notifications successfully',
      () async {
        // Arrange
        when(mockNotificationRepository.scheduleRecurringNotifications(
          any,
          any,
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await usecase(tIntervalDuration, tCount);

        // Assert
        expect(result, const Right(null));
        verify(mockNotificationRepository.scheduleRecurringNotifications(
          tIntervalDuration,
          tCount,
        ));
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );

    test(
      'should return failure when scheduling fails',
      () async {
        // Arrange
        final tFailure = NotificationFailure('Failed to schedule notifications');
        when(mockNotificationRepository.scheduleRecurringNotifications(
          any,
          any,
        )).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase(tIntervalDuration, tCount);

        // Assert
        expect(result, Left(tFailure));
        verify(mockNotificationRepository.scheduleRecurringNotifications(
          tIntervalDuration,
          tCount,
        ));
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );
  });
}
