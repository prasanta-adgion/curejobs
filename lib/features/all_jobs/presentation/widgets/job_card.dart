import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/entities/job.dart';
import '../formatters/job_formatter.dart';

/// A job listing as a white bordered card: title with badge, employer and
/// city, highlighted requirements, match reasons, then salary and posted
/// time. Tapping the card opens the job.
class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, this.onTap});

  final Job job;
  final VoidCallback? onTap;

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
    final posted = JobFormatter.posted(job.publishedAt, now);
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
    final match = _matchSummary(job.matchReasons);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final green = isDark ? AppColors.successDark : AppColors.success;

    final Widget? badge = job.isSponsored
        ? _Badge(
            label: job.sponsoredLabel ?? 'Sponsored',
            color: scheme.primary,
            background: scheme.primaryContainer,
          )
        : job.isNewAt(now)
        ? const _Badge(
            label: 'New',
            color: AppColors.success,
            background: AppColors.successLight,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: badge,
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
                if (match != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: green,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Divider(height: 1, thickness: 1, color: borderColor),
                const SizedBox(height: 10),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (posted.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: scheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        posted,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Your field: Nursing", "Near you: Kolkata" → "Your field · Near you".
  static String? _matchSummary(List<String> reasons) {
    if (reasons.isEmpty) return null;
    return reasons.map((r) => r.split(':').first.trim()).join(' · ');
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
