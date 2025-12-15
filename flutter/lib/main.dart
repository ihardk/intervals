import 'package:flutter/material.dart';
import 'core/di/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/settings/domain/usecases/get_app_settings.dart';
import 'features/notifications/data/services/notification_service.dart';
import 'shared/navigation/app_router.dart';
import 'shared/navigation/notification_handler.dart';
import 'package:home_widget/home_widget.dart';
import 'package:go_router/go_router.dart';
import 'features/notifications/domain/entities/notification_action.dart';
import 'features/logging/data/services/skipped_interval_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Backfill skipped intervals from last log
  final skippedIntervalService = di.sl<SkippedIntervalService>();
  await skippedIntervalService.backfillSkippedIntervals();

  // Check Onboarding Status
  final getAppSettings = di.sl<GetAppSettings>();
  final settingsResult = await getAppSettings();

  bool onboardingCompleted = false;

  settingsResult.fold(
    (failure) => onboardingCompleted = false, // Default to false on error
    (settings) => onboardingCompleted = settings.onboardingCompleted,
  );

  final router = createAppRouter(onboardingCompleted);

  // Setup notification navigation callbacks
  final notificationService = di.sl<NotificationService>();
  notificationService.setupNavigationCallbacks(
    onTap: (_) => NotificationHandler.handleNotificationTap(),
    onAction: (actionId) =>
        NotificationHandler.handleNotificationAction(actionId),
    onInput: (text) => NotificationHandler.handleNotificationInput(text),
  );
  await notificationService.initialize();

  runApp(IntervalApp(router: router));

  // Check for pending notification action (e.g., Voice button tapped while app was closed)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final pendingAction = NotificationHandler.consumePendingAction();
    if (pendingAction != null) {
      print('main: Found pending action: $pendingAction');
      router.go('/', extra: pendingAction);
    }
  });

  // Handle Home Widget Interactions
  _setupHomeWidget(router);
}

void _setupHomeWidget(GoRouter router) async {
  // Handle app launch from widget
  final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  if (uri != null) {
    _handleWidgetUri(uri, router);
  }

  // Handle widget clicks while app is running
  HomeWidget.widgetClicked.listen((uri) {
    if (uri != null) {
      _handleWidgetUri(uri, router);
    }
  });
}

void _handleWidgetUri(Uri uri, GoRouter router) {
  if (uri.host == 'log') {
    // interval://log/text or interval://log/voice
    final type = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    if (type == 'text') {
      router.go('/', extra: NotificationAction.text);
    } else if (type == 'voice') {
      router.go('/', extra: NotificationAction.voice);
    }
  }
}

class IntervalApp extends StatelessWidget {
  final RouterConfig<Object> router;

  const IntervalApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Interval',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
