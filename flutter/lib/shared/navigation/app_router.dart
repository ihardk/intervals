import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/logging/presentation/pages/logging_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/onboarding/presentation/pages/interval_selection_page.dart';
import '../../features/notifications/domain/entities/notification_action.dart';
import '../../features/categories/presentation/pages/category_list_page.dart';
import '../../features/categories/presentation/pages/category_edit_page.dart';
import '../../features/categories/domain/entities/category.dart';
import '../widgets/main_shell.dart';

/// Global navigation key for handling deep links
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

/// App Router - defines all routes using go_router
/// Follows Same structure as React Native: Onboarding → MainTabs
GoRouter createAppRouter(bool onboardingCompleted) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboardingCompleted ? '/' : '/onboarding/welcome',
    routes: [
      // Main Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'log',
            pageBuilder: (context, state) {
              // Handle deep link from notification with action
              final action = state.extra as NotificationAction?;
              return NoTransitionPage(
                child: LoggingPage(initialAction: action),
              );
            },
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryPage(),
            ),
          ),
          GoRoute(
            path: '/insights',
            name: 'insights',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InsightsPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
            routes: [
              GoRoute(
                path: 'categories',
                builder: (context, state) => const CategoryListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const CategoryEditPage(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final category = state.extra as Category;
                      return CategoryEditPage(category: category);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/onboarding/interval',
        name: 'interval_selection',
        builder: (context, state) => const IntervalSelectionPage(),
      ),
    ],
  );
}
