import 'package:flutter/material.dart';

import 'dashboard_tab.dart';

/// Bottom navigation for the dashboard shell.
class DashboardBottomNavBar extends StatelessWidget {
  const DashboardBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final DashboardTab currentTab;
  final ValueChanged<DashboardTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (final tab in DashboardTab.values)
                Expanded(
                  child: _NavItem(
                    tab: tab,
                    selected: tab == currentTab,
                    onTap: () => onTabSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final DashboardTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                selected ? tab.activeIcon : tab.icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
