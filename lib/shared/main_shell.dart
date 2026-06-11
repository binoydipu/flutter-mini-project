// ============================================================
// main_shell.dart — The main app layout with bottom navigation
// ============================================================
// After login, this is the "container" for the entire app.
// It has a BottomNavigationBar with 3 tabs:
//   1. Home
//   2. Appointments
//   3. Profile
//
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_project/core/theme/app_theme.dart';

/// MainShell — wraps the 3 bottom navigation tabs.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem(
      path: '/home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _TabItem(
      path: '/search',
      icon: Icons.search,
      activeIcon: Icons.search,
      label: 'Search',
    ),
    _TabItem(
      path: '/remainder',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Reminders',
    ),
    _TabItem(
      path: '/chat',
      icon: Icons.message_outlined,
      activeIcon: Icons.message,
      label: 'Chat',
    ),
    _TabItem(
      path: '/profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabs.indexWhere((t) => location.startsWith(t.path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      // The body shows the content of the currently selected tab.
      // GoRouter handles which screen to display here.
      body: child,

      // ── Bottom Navigation Bar ──
      // Material 3's NavigationBar (modern replacement for BottomNavigationBar)
      bottomNavigationBar: NavigationBar(
        // Which tab is currently selected
        selectedIndex: currentIndex,

        // Called when user taps a different tab
        onDestinationSelected: (index) => context.go(_tabs[index].path),

        // The 3 tab items
        destinations: _tabs.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon, color: AppTheme.primaryColor),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
