import 'package:go_router/go_router.dart';
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
    if (actionId == null) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    // Map action ID to NotificationAction enum
    final action = switch (actionId) {
      'text' => NotificationAction.text,
      'voice' => NotificationAction.voice,
      'skip' => NotificationAction.skip,
      _ => null,
    };

    if (action == NotificationAction.skip) {
      // Skip action - don't navigate, just dismiss
      return;
    }

    if (action != null) {
      // Navigate to logging page with preselected action
      context.go('/', extra: action);
    }
  }
}
