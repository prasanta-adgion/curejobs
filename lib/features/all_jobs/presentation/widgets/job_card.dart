import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/entities/job.dart';
import '../formatters/job_formatter.dart';

/// A job listing as a white bordered card: title with badge, employer and
/// city, highlighted requirements, then salary, posted date and Apply.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.isApplied = false,
    this.onTap,
    this.onApply,
  });

  final Job job;

  /// Shows a green "Applied" label instead of the Apply button.
  final bool isApplied;
  final VoidCallback? onTap;

  /// Defaults to [onTap] when not set.
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final now = DateTime.now();
    final salary = JobFormatter.salary(job);
    final posted = _postedLabel(JobFormatter.posted(job.publishedAt, now));
    final subtitle = [
      job.organization.name,
      ?JobFormatter.location(job),
    ].join(' · ');
    final highlightTags = <(IconData, String)>[
      if (JobFormatter.experience(job) case final experience?)
        (Icons.work_outline_rounded, experience),
      (Icons.schedule_rounded, JobFormatter.employmentType(job.employmentType)),
      if (job.specializationName case final specialization?)
        (Icons.monitor_heart_outlined, specialization),
    ];
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final radius = BorderRadius.circular(AppRadius.medium);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        job.title,
                        maxLines: 1,
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 15,
                      color: scheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (icon, label) in highlightTags)
                      _Highlight(icon: icon, label: label),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, thickness: 1, color: borderColor),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (salary == null)
                            Text('Salary not disclosed', style: muted)
                          else
                            Text.rich(
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (posted != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: scheme.outline,
                                ),
                                const SizedBox(width: 4),
                                Text(posted, style: muted),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isApplied)
                      const _AppliedLabel()
                    else
                      FilledButton(
                        onPressed: onApply ?? onTap,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Posted today", "Posted 4 days ago", "Posted 29 Sep".
  static String? _postedLabel(String posted) {
    if (posted.isEmpty) return null;
    final lower = posted == 'Today' || posted == 'Yesterday'
        ? posted.toLowerCase()
        : posted;
    return 'Posted $lower';
  }
}

/// Requirement chip in the brand colour, so key facts stand out.
class _Highlight extends StatelessWidget {
  const _Highlight({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.16) : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.small - 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppliedLabel extends StatelessWidget {
  const _AppliedLabel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? AppColors.successDark : AppColors.success;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.16) : AppColors.successLight,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            'Applied',
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
