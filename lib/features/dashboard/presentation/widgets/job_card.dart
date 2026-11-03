import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/entities/job.dart';
import '../formatters/job_formatter.dart';

/// A single job listing as a flat list row: employer, title, tags, salary
/// and post date. Rows are separated by thin dividers, not boxed in cards.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.isSaved = false,
    this.onTap,
    this.onSaveTap,
  });

  final Job job;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSaveTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final now = DateTime.now();
    final employer = job.organization.name;
    final salary = JobFormatter.salary(job);
    final tags = [
      JobFormatter.employmentType(job.employmentType),
      ?JobFormatter.experience(job),
      ?JobFormatter.location(job),
      ?job.specializationName,
    ];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EmployerLogo(
                  initials: JobFormatter.initials(employer),
                  accent: JobFormatter.accent(job.organization.id),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              job.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (job.isSponsored) ...[
                            const SizedBox(width: 6),
                            _Badge(
                              label: job.sponsoredLabel ?? 'Sponsored',
                              color: scheme.primary,
                              background: scheme.primaryContainer,
                            ),
                          ] else if (job.isNewAt(now)) ...[
                            const SizedBox(width: 6),
                            const _Badge(
                              label: 'New',
                              color: AppColors.success,
                              background: AppColors.successLight,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              employer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSaveTap,
                  tooltip: isSaved ? 'Remove from saved' : 'Save job',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? scheme.primary : scheme.outline,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (final tag in tags) _Tag(label: tag)],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: salary == null
                            ? Text('Salary not disclosed', style: muted)
                            : Text.rich(
                                TextSpan(
                                  text: salary,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: JobFormatter.salaryPeriod(
                                        job.salaryPeriod,
                                      ),
                                      style: muted,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Text(
                        JobFormatter.posted(job.publishedAt, now),
                        style: muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployerLogo extends StatelessWidget {
  const _EmployerLogo({required this.initials, required this.accent});

  final String initials;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: accent, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.small - 2),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
