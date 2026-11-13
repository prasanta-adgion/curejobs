import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../dashboard/domain/entities/job.dart';
import '../../../dashboard/presentation/formatters/job_formatter.dart';

part 'job_details_more_sections.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _titleCase(String s) => s
    .trim()
    .split(' ')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
    .join(' ');

/// "Kolkata, West Bengal", or null when neither is set.
String? fullLocation(Job job) {
  final parts = [job.city, job.state]
      .whereType<String>()
      .where((p) => p.trim().isNotEmpty)
      .map(_titleCase)
      .toList();
  return parts.isEmpty ? null : parts.join(', ');
}

/// Application deadline and how close it is.
class DeadlineInfo {
  const DeadlineInfo._(this.date, this.daysLeft);

  final DateTime date;
  final int daysLeft;

  static DeadlineInfo? of(DateTime? deadline, DateTime now) {
    if (deadline == null) return null;
    final local = deadline.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    return DeadlineInfo._(local, day.difference(today).inDays);
  }

  bool get isClosed => daysLeft < 0;
  bool get isUrgent => !isClosed && daysLeft <= 7;

  String get dateLabel => '${date.day} ${_months[date.month - 1]}';

  /// "17 days left", "Last day today", "Closed".
  String get countdown => switch (daysLeft) {
    < 0 => 'Closed',
    0 => 'Last day today',
    1 => '1 day left',
    _ => '$daysLeft days left',
  };

  String get shortLabel => switch (daysLeft) {
    < 0 => 'Applications closed',
    0 => 'Last day to apply',
    _ => '$countdown to apply',
  };

  Color color(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (isClosed) return dark ? AppColors.errorDark : const Color(0xFFDC2626);
    return dark ? AppColors.warningDark : const Color(0xFFB45309);
  }
}

Color _border(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkBorder
    : AppColors.lightBorder;

Color _brand(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkPrimary
    : AppColors.primary;

Color _brandTint(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkPrimary.withValues(alpha: 0.16)
    : AppColors.primaryLight;

/// Badges, title, employer, location and the salary box with Apply.
class JobDetailsHeader extends StatelessWidget {
  const JobDetailsHeader({
    super.key,
    required this.job,
    required this.now,
    required this.onApply,
  });

  final Job job;
  final DateTime now;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = _brand(context);
    final salary = JobFormatter.salary(job);
    final location = fullLocation(job);
    final closed =
        job.isClosed ||
        (DeadlineInfo.of(job.applicationDeadline, now)?.isClosed ?? false);
    final isNew = job.isNewAt(now);
    final badges = [
      if (job.isSponsored)
        _Badge(
          label: job.sponsoredLabel ?? 'Sponsored',
          color: brand,
          background: _brandTint(context),
        ),
      if (job.isFeatured)
        _Badge(
          label: job.featuredLabel ?? 'Featured',
          color: AppColors.warning,
          background: AppColors.warningLight,
        ),
      if (isNew)
        const _Badge(
          label: 'New',
          color: AppColors.success,
          background: AppColors.successLight,
        ),
      if (closed)
        _Badge(
          label: 'Not accepting applications',
          color: AppColors.error,
          background: AppColors.errorLight,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: _border(context))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badges.isNotEmpty) ...[
            Wrap(spacing: 6, runSpacing: 6, children: badges),
            const SizedBox(height: 10),
          ],
          Text(
            job.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _IconLine(
            icon: Icons.local_hospital_outlined,
            text: job.organization.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (location != null) ...[
            const SizedBox(height: 4),
            _IconLine(icon: Icons.location_on_outlined, text: location),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            decoration: BoxDecoration(
              color: _brandTint(context),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salary',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: brand,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (salary == null)
                        Text(
                          'Not disclosed',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text.rich(
                          TextSpan(
                            text: salary,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: JobFormatter.salaryPeriod(
                                  job.salaryPeriod,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: brand,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: closed ? null : onApply,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small + 2),
                    ),
                  ),
                  child: Text(closed ? 'Closed' : 'Apply now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Experience, job type, posted date and deadline as a 2×2 grid.
class JobOverviewSection extends StatelessWidget {
  const JobOverviewSection({
    super.key,
    required this.job,
    required this.now,
    required this.deadline,
  });

  final Job job;
  final DateTime now;
  final DeadlineInfo? deadline;

  @override
  Widget build(BuildContext context) {
    final posted = JobFormatter.posted(job.publishedAt, now);
    final tiles = <Widget>[
      _FactTile(
        icon: Icons.work_outline_rounded,
        label: 'Experience',
        value: JobFormatter.experience(job) ?? 'Any',
      ),
      _FactTile(
        icon: Icons.schedule_rounded,
        label: 'Job type',
        value: JobFormatter.employmentType(job.employmentType),
      ),
      if (posted.isNotEmpty)
        _FactTile(
          icon: Icons.calendar_today_outlined,
          label: 'Posted',
          value: posted,
        ),
      if (deadline case final d?)
        _FactTile(
          icon: Icons.hourglass_bottom_rounded,
          label: 'Apply before',
          value: '${d.dateLabel} · ${d.countdown}',
          accent: d.isUrgent || d.isClosed ? d.color(context) : null,
        ),
    ];

    return _Section(
      icon: Icons.list_alt_rounded,
      title: 'Job overview',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 8) / 2;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tile in tiles) SizedBox(width: width, child: tile),
            ],
          );
        },
      ),
    );
  }
}

class JobSkillsSection extends StatelessWidget {
  const JobSkillsSection({super.key, required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = _brand(context);
    return _Section(
      icon: Icons.auto_awesome_outlined,
      title: 'Skills required',
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final skill in skills)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _brandTint(context),
                borderRadius: BorderRadius.circular(AppRadius.small - 2),
              ),
              child: Text(
                skill,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class JobDepartmentSection extends StatelessWidget {
  const JobDepartmentSection({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final rows = [
      if (job.categoryName case final c?) ('Category', c),
      if (job.specializationName case final s?) ('Specialisation', s),
    ];
    return _Section(
      icon: Icons.medical_services_outlined,
      title: 'Department',
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 17, color: _border(context)),
            _InfoRow(label: rows[i].$1, value: rows[i].$2),
          ],
        ],
      ),
    );
  }
}

class JobEmployerSection extends StatelessWidget {
  const JobEmployerSection({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final location = fullLocation(job);
    return _Section(
      icon: Icons.local_hospital_outlined,
      title: 'About the employer',
      child: Row(
        children: [
          // TODO: show the logo from organization.logoFileId.
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _brandTint(context),
              borderRadius: BorderRadius.circular(AppRadius.small + 2),
            ),
            child: Icon(Icons.apartment_rounded, color: _brand(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.organization.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (location != null)
                  Text(
                    location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: _border(context)),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _brand(context)),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Tints the tile, e.g. amber for a close deadline.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final iconColor = accent ?? _brand(context);
    final background =
        accent?.withValues(alpha: 0.10) ??
        scheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.small + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent ?? scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: accent ?? scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text, this.style});

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.outline),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                style ??
                theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
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
