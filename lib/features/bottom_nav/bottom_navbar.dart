import 'package:curejobs/features/applied_application/presentation/page/my_applications_page.dart';
import 'package:flutter/material.dart';

import '../all_jobs/presentation/pages/all_jobs_page.dart';
import 'dashboard_bottom_nav_bar.dart';
import 'dashboard_tab_enum.dart';
import '../auth/login/presentation/pages/login_page.dart';
import '../dashboard/presentation/pages/dashboard_home_page.dart';
import '../profile/presentation/pages/profile_page.dart';

/// Dashboard shell: builds each tab on first open, then keeps it alive.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _currentTab = ValueNotifier(DashboardTab.home);

  // Tabs the user has opened. Only these are built, so a tab's APIs run on
  // its first open instead of when the dashboard starts.
  final _visited = <DashboardTab>{DashboardTab.home};

  // Built pages are cached so switching tabs never recreates them.
  final _cache = <DashboardTab, Widget>{};

  Widget _buildTab(DashboardTab tab) => switch (tab) {
        DashboardTab.home => const DashboardHomePage(),
        DashboardTab.profile => ProfilePage(onLoggedOut: _showLogin),
        DashboardTab.applied => MyApplicationsPage(),
        DashboardTab.jobs => const AllJobsPage(),
        _ => _ComingSoonTab(tab: tab),
      };

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
        builder: (context, tab, _) {
          _visited.add(tab);
          return IndexedStack(
            index: tab.index,
            children: [
              for (final t in DashboardTab.values)
                _visited.contains(t)
                    ? _cache.putIfAbsent(t, () => _buildTab(t))
                    : const SizedBox.shrink(),
            ],
          );
        },
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
            Image.asset(
              tab.iconAsset(selected: true),
              width: 40,
              height: 40,
            ),
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
