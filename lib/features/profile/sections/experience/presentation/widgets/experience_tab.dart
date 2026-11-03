import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';
import '../../../../presentation/models/candidate_profile.dart';
import '../../../../shared/widgets/profile_section.dart';

/// Work history as a vertical timeline, newest first.
class ExperienceTab extends StatelessWidget {
  const ExperienceTab({
    super.key,
    required this.experience,
    this.onAdd,
    this.onEdit,
  });

  final List<ProfileExperience> experience;
  final VoidCallback? onAdd;
  final ValueChanged<ProfileExperience>? onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ProfileSection(
          title: '${experience.length} positions',
          showDivider: false,
          action: SectionAction(
            label: 'Add',
            icon: Icons.add,
            onPressed: onAdd,
          ),
          child: Column(
            children: [
              for (var i = 0; i < experience.length; i++)
                _TimelineEntry(
                  item: experience[i],
                  isLast: i == experience.length - 1,
                  onEdit: onEdit == null ? null : () => onEdit!(experience[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.item, required this.isLast, this.onEdit});

  final ProfileExperience item;
  final bool isLast;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isCurrent ? scheme.primary : scheme.surface,
                    border: Border.all(
                      color: item.isCurrent
                          ? scheme.primaryContainer
                          : scheme.outlineVariant,
                      width: item.isCurrent ? 3 : 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: scheme.outlineVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.role,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(item.employer, style: muted),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: onEdit,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: scheme.outline,
                          ),
                        ),
                      ],
                    ),
                    if (item.isCurrent || item.employmentType != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (item.isCurrent)
                            const _Pill(
                              label: 'Current',
                              color: AppColors.success,
                              background: AppColors.successLight,
                            ),
                          if (item.employmentType != null)
                            _Pill(
                              label: item.employmentType!,
                              color: scheme.onSurfaceVariant,
                              background: scheme.surfaceContainerHighest,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${item.period} · ${item.duration}',
                            style: muted,
                          ),
                        ),
                      ],
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          item.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
