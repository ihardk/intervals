import 'package:flutter/material.dart';
import 'core/di/injection.dart' as di;
import 'core/theme/app_theme.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const IntervalApp());
}

class IntervalApp extends StatelessWidget {
  const IntervalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interval',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const PlaceholderHomeScreen(),
    );
  }
}

/// Temporary placeholder screen until we build the real UI
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Interval',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Minimalist Awareness Logger',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
