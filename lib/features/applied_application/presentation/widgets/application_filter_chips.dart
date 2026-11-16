import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../models/application_ui_model.dart';

/// Horizontal filter row: All, Applied, Under review, Shortlisted,
/// Selected, Rejected, Withdrawn. Styled like the dashboard job filters:
/// the selected tag turns violet.
class ApplicationFilterChips extends StatelessWidget {
  const ApplicationFilterChips({
    super.key,
    required this.total,
    required this.counts,
    required this.selected,
    required this.onSelected,
  });

  final int total;
  final Map<ApplicationStatus, int> counts;

  /// Null means "All".
  final ApplicationStatus? selected;
  final ValueChanged<ApplicationStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterTag(
            label: 'All',
            count: total,
            active: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final s in ApplicationStatus.values) ...[
            const SizedBox(width: 8),
            _FilterTag(
              label: s.label,
              count: counts[s] ?? 0,
              active: selected == s,
              onTap: () => onSelected(s),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterTag extends StatelessWidget {
  const _FilterTag({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadius.small);
    final foreground = active ? scheme.onPrimaryContainer : scheme.onSurface;

    return Material(
      color: active ? scheme.primaryContainer : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: active ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text.rich(
            TextSpan(
              text: label,
              children: [
                TextSpan(
                  text: '  $count',
                  style: TextStyle(
                    color: active ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            style: theme.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
