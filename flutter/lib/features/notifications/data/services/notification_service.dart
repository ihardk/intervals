import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/widgets.dart'; // For WidgetsFlutterBinding
import '../../../../core/di/injection.dart' as di;
import '../../../../shared/navigation/notification_handler.dart';

/// Notification service wrapper for flutter_local_notifications
/// Handles platform-specific notification operations
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Notification channel constants
  static const String _channelId = 'interval_channel';
  static const String _channelName = 'Interval Notifications';
  static const String _channelDescription =
      'Notifications for interval logging';

  // Action IDs
  static const String actionText = 'text';
  static const String actionVoice = 'voice';
  static const String actionSkip = 'skip';

  // Callback for handling notification taps
  Function(String?)? onNotificationTap;
  Function(String?)? onNotificationAction;
  Function(String)? onNotificationInput;

  /// Initialize notification service
  Future<bool> initialize() async {
    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with callback handlers
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onNotificationResponse,
      );

      return initialized ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final result = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      } else if (Platform.isAndroid) {
        final androidPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final result = await androidPlugin?.requestNotificationsPermission();
        return result ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.areNotificationsEnabled() ?? false;
      } else if (Platform.isIOS) {
        // iOS doesn't provide a direct way to check, assume enabled if we have permission
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Schedule a notification at a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          actionText,
          'Log Activity',
          showsUserInterface: false, // Handle in background/inline
          inputs: [
            AndroidNotificationActionInput(
              label: 'What are you doing?',
            ),
          ],
        ),
        AndroidNotificationAction(
          actionVoice,
          'Voice',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          actionSkip,
          'Skip',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a notification by ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notification requests
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Handle notification response (tap or action)
  @pragma('vm:entry-point')
  static Future<void> _onNotificationResponse(
      NotificationResponse response) async {
    // Ensure properly initialized in background isolate
    if (response.input != null || response.actionId != null) {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await di.init();
      } catch (e) {
        // Ignore if already initialized
      }
    }

    final instance = NotificationService();

    if (response.input != null && response.input!.isNotEmpty) {
      // User typed text in the notification
      if (instance.onNotificationInput != null) {
        instance.onNotificationInput!(response.input!);
      } else {
        // Fallback to static handler if callback not set (background isolate)
        await NotificationHandler.handleNotificationInput(response.input!);
      }
    } else if (response.actionId != null) {
      // User tapped an action button
      if (instance.onNotificationAction != null) {
        instance.onNotificationAction!(response.actionId);
      } else {
        NotificationHandler.handleNotificationAction(response.actionId);
      }
    } else {
      // User tapped the notification itself
      if (instance.onNotificationTap != null) {
        instance.onNotificationTap!(response.payload);
      } else {
        NotificationHandler.handleNotificationTap();
      }
    }
  }

  /// Set up navigation callbacks
  /// Should be called after router is initialized
  void setupNavigationCallbacks({
    required Function(String?) onTap,
    required Function(String?) onAction,
    required Function(String) onInput,
  }) {
    onNotificationTap = onTap;
    onNotificationAction = onAction;
    onNotificationInput = onInput;
  }
}
