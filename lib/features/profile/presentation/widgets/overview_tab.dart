import 'package:flutter/material.dart';

import '../models/candidate_profile.dart';
import 'logout_section.dart';
import 'profile_section.dart';

/// First tab: activity numbers, about, current role and skills.
class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.profile,
    this.onEditAbout,
    this.onEditSkills,
  });

  final CandidateProfile profile;
  final VoidCallback? onEditAbout;
  final VoidCallback? onEditSkills;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = profile.currentRole;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ProfileSection(
          title: 'This month',
          showDivider: false,
          child: _Stats(stats: profile.stats),
        ),
        ProfileSection(
          title: 'About',
          action: SectionAction(
            label: 'Edit',
            icon: Icons.edit_outlined,
            onPressed: onEditAbout,
          ),
          child: Text(
            profile.about,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        ),
        if (current != null)
          ProfileSection(
            title: 'Current role',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileIconTile(icon: Icons.local_hospital_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.role,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        current.employer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        current.period,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ProfileSection(
          title: 'Skills',
          action: SectionAction(
            label: 'Edit',
            icon: Icons.edit_outlined,
            onPressed: onEditSkills,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in profile.skills) _SkillTag(label: skill),
            ],
          ),
        ),
        const LogoutSection(),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _Stat(value: stats.views, label: 'Profile views'),
          ),
          VerticalDivider(width: 24, color: divider),
          Expanded(
            child: _Stat(value: stats.applied, label: 'Applied'),
          ),
          VerticalDivider(width: 24, color: divider),
          Expanded(
            child: _Stat(value: stats.shortlisted, label: 'Shortlisted'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SkillTag extends StatelessWidget {
  const _SkillTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(label, style: theme.textTheme.bodySmall),
    );
  }
}
