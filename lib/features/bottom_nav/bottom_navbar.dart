import 'package:flutter/material.dart';

import 'dashboard_bottom_nav_bar.dart';
import 'dashboard_tab.dart';
import '../auth/login/presentation/pages/login_page.dart';
import '../dashboard/presentation/pages/dashboard_home_page.dart';
import '../profile/presentation/pages/profile_page.dart';

/// Dashboard shell: keeps each tab alive and switches via the bottom bar.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _currentTab = ValueNotifier(DashboardTab.home);

  // Built once so switching tabs never recreates the pages.
  late final _pages = [
    for (final tab in DashboardTab.values)
      switch (tab) {
        DashboardTab.home => const DashboardHomePage(),
        DashboardTab.profile => ProfilePage(onLoggedOut: _showLogin),
        _ => _ComingSoonTab(tab: tab),
      },
  ];

  /// Replaces everything with the login screen; signing in again opens a
  /// fresh dashboard.
  void _showLogin() {
    final navigator = Navigator.of(context);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(
          onLoggedIn: (_) => navigator.pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const DashboardPage()),
          ),
        ),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _currentTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: _currentTab,
        builder: (context, tab, _) =>
            IndexedStack(index: tab.index, children: _pages),
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _currentTab,
        builder: (context, tab, _) => DashboardBottomNavBar(
          currentTab: tab,
          onTabSelected: (selected) => _currentTab.value = selected,
        ),
      ),
    );
  }
}

/// Placeholder for tabs that aren't built yet.
class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.tab});

  final DashboardTab tab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(tab.label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Coming soon',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
