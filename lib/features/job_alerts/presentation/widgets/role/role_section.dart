import 'package:flutter/material.dart';

import '../../bloc/job_alerts_bloc.dart';
import '../alert_add_button.dart';
import '../removable_chip.dart';

/// Role filter: a Category card and a Specialization card. Each shows its
/// picks as chips with an Add / Add more button under them.
class RoleSection extends StatelessWidget {
  const RoleSection({
    super.key,
    required this.state,
    required this.onPickCategories,
    required this.onRemoveCategory,
    required this.onPickSpecializations,
    required this.onRemoveSpecialization,
  });

  final JobAlertsState state;
  final VoidCallback onPickCategories;
  final ValueChanged<String> onRemoveCategory;
  final VoidCallback onPickSpecializations;
  final ValueChanged<String> onRemoveSpecialization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = state.selectedCategories;
    final specializations = state.selectedSpecializations;
    final hasCategories = categories.isNotEmpty;
    final examples = state.categories.take(3).map((c) => c.name).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Which jobs should we tell you about?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        RoleStepCard(
          icon: Icons.category_outlined,
          title: 'Category',
          subtitle: hasCategories ? null : 'Now: all categories',
          count: categories.length,
          children: [
            if (hasCategories) ...[
              _ChipWrap(
                children: [
                  for (final c in categories)
                    RemovableChip(
                      label: c.name,
                      onRemove: () => onRemoveCategory(c.id),
                    ),
                ],
              ),
              AlertAddButton(
                label: 'Add more categories',
                onTap: onPickCategories,
              ),
            ] else
              AlertAddButton.large(
                label: 'Add category',
                hint: examples.isEmpty ? null : '$examples…',
                onTap: onPickCategories,
              ),
          ],
        ),
        const SizedBox(height: 10),
        RoleStepCard(
          icon: Icons.medical_services_outlined,
          title: 'Specialization',
          subtitle: specializations.isEmpty ? 'Optional' : null,
          count: specializations.length,
          enabled: hasCategories,
          children: [
            if (!hasCategories)
              const AlertAddButton.locked(label: 'Add a category first')
            else if (state.loadingSpecializations && specializations.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              )
            else ...[
              if (specializations.isNotEmpty)
                _ChipWrap(
                  children: [
                    for (final s in specializations)
                      RemovableChip(
                        label: s.name,
                        onRemove: () => onRemoveSpecialization(s.id),
                      ),
                  ],
                ),
              if (state.availableSpecializations.isEmpty)
                const AlertAddButton.locked(
                  label: 'No specializations in these categories',
                )
              else
                AlertAddButton(
                  label: specializations.isEmpty
                      ? 'Add specialization'
                      : 'Add more specializations',
                  onTap: onPickSpecializations,
                ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Bordered card: icon tile, title (+ subtitle), count badge, then content.
class RoleStepCard extends StatelessWidget {
  const RoleStepCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
    this.count = 0,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int count;
  final bool enabled;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: enabled
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: enabled ? scheme.onPrimaryContainer : scheme.outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled ? null : scheme.onSurfaceVariant,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (count > 0) _CountBadge(count),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(spacing: 6, runSpacing: 6, children: children),
    );
  }
}
