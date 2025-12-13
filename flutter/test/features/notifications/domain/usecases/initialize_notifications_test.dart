import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:interval/core/errors/failures.dart';
import 'package:interval/features/notifications/domain/repositories/notification_repository.dart';
import 'package:interval/features/notifications/domain/usecases/initialize_notifications.dart';

@GenerateMocks([NotificationRepository])
import 'initialize_notifications_test.mocks.dart';

void main() {
  late InitializeNotifications usecase;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    usecase = InitializeNotifications(mockNotificationRepository);
  });

  group('InitializeNotifications', () {
    test(
      'should initialize notification service successfully',
      () async {
        // Arrange
        when(mockNotificationRepository.initialize())
            .thenAnswer((_) async => const Right(true));

        // Act
        final result = await usecase();

        // Assert
        expect(result, const Right(true));
        verify(mockNotificationRepository.initialize());
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );

    test(
      'should return failure when initialization fails',
      () async {
        // Arrange
        final tFailure = PermissionFailure('Notification permission denied');
        when(mockNotificationRepository.initialize())
            .thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase();

        // Assert
        expect(result, Left(tFailure));
        verify(mockNotificationRepository.initialize());
        verifyNoMoreInteractions(mockNotificationRepository);
      },
    );
  });
}
