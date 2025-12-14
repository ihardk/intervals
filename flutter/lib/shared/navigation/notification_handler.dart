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

  /// Handle inline text input from notification
  static Future<void> handleNotificationInput(String text) async {
    try {
      // We need to access DI here
      final createLog = GetIt.I<CreateLog>();

      await createLog(
        content: text,
        entryType: 'text',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        // category & tags will be handled by auto-categorizer or defaults
        // intervalDuration: 15, // Not part of CreateLog signature?
        // Checking CreateLog signature again: content, entryType, audioPath, category, tags, mood, timestamp.
        // It does NOT take intervalDuration. It is inferred or stored in settings?
        // Log entity usually has duration. Let's check Log entity if needed, but CreateLog usecase is the contract.
      );
    } catch (e) {
      print('Failed to save log from notification input: $e');
    }
  }
}
