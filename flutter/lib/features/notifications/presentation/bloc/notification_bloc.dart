import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cancel_all_notifications.dart';
import '../../domain/usecases/get_pending_notifications.dart';
import '../../domain/usecases/initialize_notifications.dart';
import '../../domain/usecases/request_notification_permissions.dart';
import '../../domain/usecases/schedule_interval_notification.dart';
import '../../domain/usecases/schedule_recurring_notifications.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final InitializeNotifications initializeNotifications;
  final RequestNotificationPermissions requestPermissions;
  final ScheduleIntervalNotification scheduleNotification;
  final ScheduleRecurringNotifications scheduleRecurring;
  final CancelAllNotifications cancelAll;
  final GetPendingNotifications getPendingNotifications;

  NotificationBloc({
    required this.initializeNotifications,
    required this.requestPermissions,
    required this.scheduleNotification,
    required this.scheduleRecurring,
    required this.cancelAll,
    required this.getPendingNotifications,
  }) : super(const NotificationState.initial()) {
    on<InitializeNotifications>(_onInitialize);
    on<RequestPermissions>(_onRequestPermissions);
    on<ScheduleNotification>(_onScheduleNotification);
    on<ScheduleRecurring>(_onScheduleRecurring);
    on<CancelAll>(_onCancelAll);
    on<LoadPendingNotifications>(_onLoadPendingNotifications);
  }

  Future<void> _onInitialize(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationState.loading());

    final result = await initializeNotifications();

    result.fold(
      (failure) => emit(NotificationState.error(failure.message)),
      (success) => emit(NotificationState.initialized(
        permissionsGranted: success,
        notificationsEnabled: success,
      )),
    );
  }

  Future<void> _onRequestPermissions(
    RequestPermissions event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationState.loading());

    final result = await requestPermissions();

    result.fold(
      (failure) => emit(const NotificationState.permissionDenied()),
      (granted) => emit(NotificationState.initialized(
        permissionsGranted: granted,
        notificationsEnabled: granted,
      )),
    );
  }

  Future<void> _onScheduleNotification(
    ScheduleNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationState.loading());

    final result = await scheduleNotification(event.input);

    result.fold(
      (failure) => emit(NotificationState.error(failure.message)),
      (_) => emit(const NotificationState.scheduled()),
    );
  }

  Future<void> _onScheduleRecurring(
    ScheduleRecurring event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationState.loading());

    final result = await scheduleRecurring(
      event.intervalDuration,
      event.count,
    );

    result.fold(
      (failure) => emit(NotificationState.error(failure.message)),
      (_) => emit(const NotificationState.scheduled()),
    );
  }

  Future<void> _onCancelAll(
    CancelAll event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationState.loading());

    final result = await cancelAll();

    result.fold(
      (failure) => emit(NotificationState.error(failure.message)),
      (_) => emit(const NotificationState.cancelled()),
    );
  }

  Future<void> _onLoadPendingNotifications(
    LoadPendingNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationState.loading());

    final result = await getPendingNotifications();

    result.fold(
      (failure) => emit(NotificationState.error(failure.message)),
      (notifications) => emit(NotificationState.pending(notifications)),
    );
  }
}
