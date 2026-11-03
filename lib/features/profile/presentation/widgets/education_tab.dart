import 'package:flutter/material.dart';

import '../models/candidate_profile.dart';
import 'profile_section.dart';

/// Degrees and schooling, newest first.
class EducationTab extends StatelessWidget {
  const EducationTab({
    super.key,
    required this.education,
    this.onAdd,
    this.onEdit,
  });

  final List<ProfileEducation> education;
  final VoidCallback? onAdd;
  final ValueChanged<ProfileEducation>? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ProfileSection(
          title: 'Education',
          showDivider: false,
          action: SectionAction(
            label: 'Add',
            icon: Icons.add,
            onPressed: onAdd,
          ),
          child: Column(
            children: [
              for (var i = 0; i < education.length; i++) ...[
                if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProfileIconTile(icon: Icons.school_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              education[i].degree,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(education[i].institution, style: muted),
                            Text(
                              education[i].score == null
                                  ? education[i].period
                                  : '${education[i].period} · ${education[i].score}',
                              style: muted,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: onEdit == null
                            ? null
                            : () => onEdit!(education[i]),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
