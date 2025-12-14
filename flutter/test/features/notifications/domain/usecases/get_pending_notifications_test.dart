import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/notifications/domain/entities/scheduled_notification.dart';
import 'package:interval/features/notifications/domain/repositories/notification_repository.dart';
import 'package:interval/features/notifications/domain/usecases/get_pending_notifications.dart';

@GenerateMocks([NotificationRepository])
import 'get_pending_notifications_test.mocks.dart';

void main() {
  late GetPendingNotifications usecase;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    usecase = GetPendingNotifications(mockNotificationRepository);
  });

  final tScheduledTime =
      DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch;

  final tNotifications = [
    ScheduledNotification(
      id: 1,
      scheduledTime: tScheduledTime,
      title: 'What are you doing?',
      body: 'Tap to log your activity',
      intervalDuration: 900000,
    ),
    ScheduledNotification(
      id: 2,
      scheduledTime: tScheduledTime + 900000,
      title: 'What are you doing?',
      body: 'Tap to log your activity',
      intervalDuration: 900000,
    ),
  ];

  group('GetPendingNotifications', () {
    test(
      'should get all pending notifications successfully',
      () async {
        // Arrange
        when(mockNotificationRepository.getPendingNotifications())
            .thenAnswer((_) async => Right(tNotifications));

        // Act
        final result = await usecase();

        // Assert
        expect(result, Right(tNotifications));
        verify(mockNotificationRepository.getPendingNotifications());
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );

    test(
      'should return empty list when no notifications pending',
      () async {
        // Arrange
        when(mockNotificationRepository.getPendingNotifications())
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await usecase();

        // Assert
        expect(result, isA<Right<Failure, List<ScheduledNotification>>>());
        result.fold(
          (failure) => fail('Should return Right'),
          (notifications) => expect(notifications, isEmpty),
        );
        verify(mockNotificationRepository.getPendingNotifications());
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );

    test(
      'should return failure when getting notifications fails',
      () async {
        // Arrange
        final tFailure = NotificationFailure('Failed to get notifications');
        when(mockNotificationRepository.getPendingNotifications())
            .thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase();

        // Assert
        expect(result, Left(tFailure));
        verify(mockNotificationRepository.getPendingNotifications());
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );
  });
}
