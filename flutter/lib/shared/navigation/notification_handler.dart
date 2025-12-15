import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../features/logging/domain/usecases/create_log.dart';
import '../../features/notifications/domain/entities/notification_action.dart';
import 'app_router.dart';

/// Handles notification tap and action responses
class NotificationHandler {
  /// Handle notification tap (general tap on notification body)
  static void handleNotificationTap() {
    // Navigate to logging page without preselected action
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.go('/');
    }
  }

  /// Handle notification action button (Text/Voice/Skip)
  static void handleNotificationAction(String? actionId) {
    print(
        'NotificationHandler: handleNotificationAction called with: $actionId');

    if (actionId == null) return;

    final context = rootNavigatorKey.currentContext;
    print(
        'NotificationHandler: context is ${context == null ? 'NULL' : 'available'}');

    // Map action ID to NotificationAction enum
    final action = switch (actionId) {
      'text' => NotificationAction.text,
      'voice' => NotificationAction.voice,
      'skip' => NotificationAction.skip,
      _ => null,
    };

    if (action == NotificationAction.skip) {
      // Skip action - create skipped entry and dismiss
      _createSkippedEntry();
      return;
    }

    if (action != null && context != null) {
      print('NotificationHandler: Navigating with action: $action');
      // Navigate to logging page with preselected action
      context.go('/', extra: action);
    } else if (action != null && context == null) {
      print('NotificationHandler: Context null, storing action for later');
      // Store action to be picked up when app initializes
      _pendingAction = action;
    }
  }

  // Store pending action for when context becomes available
  static NotificationAction? _pendingAction;

  /// Get and clear any pending action (call this from main after router init)
  static NotificationAction? consumePendingAction() {
    final action = _pendingAction;
    _pendingAction = null;
    return action;
  }

  /// Create a skipped log entry
  static Future<void> _createSkippedEntry() async {
    try {
      final createLog = GetIt.I<CreateLog>();
      await createLog(
        content: 'Skipped',
        entryType: 'skipped',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      print('NotificationHandler: Created skipped entry');

      // Cancel the notification
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancel(0); // Our notification uses ID 0
    } catch (e) {
      print('NotificationHandler: Failed to create skipped entry: $e');
    }
  }

  /// Handle inline text input from notification
  static Future<void> handleNotificationInput(String text,
      {int? notificationId}) async {
    try {
      print('NotificationHandler: Received input: "$text"');

      // We need to access DI here
      final createLog = GetIt.I<CreateLog>();
      print('NotificationHandler: Got CreateLog from DI');

      final result = await createLog(
        content: text,
        entryType: 'text',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // IMPORTANT: CreateLog returns Either<Failure, Log> - we MUST check it!
      result.fold(
        (failure) => print(
            'NotificationHandler: FAILED to create log: ${failure.message}'),
        (log) => print(
            'NotificationHandler: SUCCESS - Log created with id ${log.id}'),
      );

      // Cancel the notification to stop the spinner
      if (notificationId != null) {
        // Using the plugin directly to avoid circular dependency with NotificationService
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin.cancel(notificationId);
      }
    } catch (e) {
      print('Failed to save log from notification input: $e');
    }
  }
}
