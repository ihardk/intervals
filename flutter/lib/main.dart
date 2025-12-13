import 'package:flutter/material.dart';
import 'core/di/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/settings/domain/usecases/get_app_settings.dart';
import 'shared/navigation/app_router.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Check Onboarding Status
  final getAppSettings = di.sl<GetAppSettings>();
  final settingsResult = await getAppSettings();

  bool onboardingCompleted = false;

  settingsResult.fold(
    (failure) => onboardingCompleted = false, // Default to false on error
    (settings) => onboardingCompleted = settings.onboardingCompleted,
  );

  final router = createAppRouter(onboardingCompleted);

  runApp(IntervalApp(router: router));
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
