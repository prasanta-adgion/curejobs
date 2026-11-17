import 'package:flutter/material.dart';

import 'dashboard_tab_enum.dart';

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
          height: 68,
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
    // Icons are tinted from the theme, so dark mode gets the lighter primary.
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    const duration = Duration(milliseconds: 220);

    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top indicator line on the selected tab.
            Positioned(
              top: 0,
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: selected ? 32 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(3),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Soft tile behind the selected icon.
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  width: 52,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.primaryContainer
                        : scheme.primaryContainer.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    tab.iconAsset(selected: selected),
                    width: 24,
                    height: 24,
                    color: color,
                    // Keep both states decoded so switching doesn't flicker.
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  style: (theme.textTheme.labelSmall ?? const TextStyle())
                      .copyWith(
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                  child: Text(tab.label),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
