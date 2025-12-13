import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';

/// Main Shell - Scaffold with Bottom Navigation Bar
/// Wraps all main screens (Log, History, Insights, Settings)
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  // Get current index based on route
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/insights')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // Default to Log tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.grey1, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _getCurrentIndex(context),
          onTap: (index) => _onItemTapped(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.black,
          selectedItemColor: AppColors.white,
          unselectedItemColor: AppColors.grey3,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add_circled),
              activeIcon: Icon(CupertinoIcons.add_circled_solid),
              label: 'Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.list_bullet),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar),
              activeIcon: Icon(CupertinoIcons.chart_bar_fill),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              activeIcon: Icon(CupertinoIcons.settings_solid),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/insights');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
