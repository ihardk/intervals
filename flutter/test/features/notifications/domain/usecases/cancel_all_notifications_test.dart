import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/notifications/domain/repositories/notification_repository.dart';
import 'package:interval/features/notifications/domain/usecases/cancel_all_notifications.dart';

@GenerateMocks([NotificationRepository])
import 'cancel_all_notifications_test.mocks.dart';

void main() {
  late CancelAllNotifications usecase;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    usecase = CancelAllNotifications(mockNotificationRepository);
  });

  group('CancelAllNotifications', () {
    test(
      'should cancel all notifications successfully',
      () async {
        // Arrange
        when(mockNotificationRepository.cancelAllNotifications())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await usecase();

        // Assert
        expect(result, const Right(null));
        verify(mockNotificationRepository.cancelAllNotifications());
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );

    test(
      'should return failure when cancellation fails',
      () async {
        // Arrange
        final tFailure = NotificationFailure('Failed to cancel notifications');
        when(mockNotificationRepository.cancelAllNotifications())
            .thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase();

        // Assert
        expect(result, Left(tFailure));
        verify(mockNotificationRepository.cancelAllNotifications());
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );
  });
}
