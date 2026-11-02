import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../models/dashboard_job.dart';

/// A single job listing: employer, title, tags, salary and post date.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onSaveTap,
  });

  final DashboardJob job;
  final VoidCallback? onTap;
  final VoidCallback? onSaveTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadius.large);

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EmployerLogo(initials: job.initials, accent: job.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                job.employer,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (job.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded,
                                  size: 15, color: AppColors.verified),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onSaveTap,
                    tooltip: job.isSaved ? 'Remove from saved' : 'Save job',
                    icon: Icon(
                      job.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: job.isSaved
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final tag in job.tags) _Tag(label: tag)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 14, bottom: 12),
                child: Divider(height: 1, color: scheme.outlineVariant),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        text: job.salary,
                        style: theme.textTheme.titleSmall,
                        children: [
                          TextSpan(
                            text: ' /month',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      job.postedLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: job.isNew
                            ? AppColors.success
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: accent),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurface),
      ),
    );
  }
}
