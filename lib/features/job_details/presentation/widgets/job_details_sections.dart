import 'package:curejobs/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../../all_jobs/presentation/formatters/job_formatter.dart';
import '../../../apply_job/presentation/widgets/apply_flow_widgets.dart';

part 'job_details_more_sections.dart';

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

/// Up to two initials for the employer logo placeholder.
String _initials(String name) {
  final words = name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(w[0]))
      .toList();
  if (words.isEmpty) return '?';
  return words.take(2).map((w) => w[0].toUpperCase()).join();
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

  String get dateLabel => '${date.day} ${DateTimeUtils.months[date.month - 1]}';

  String get fullDateLabel => '$dateLabel ${date.year}';

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

  Color background(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark) return color(context).withValues(alpha: 0.14);
    return isClosed ? AppColors.errorLight : AppColors.warningLight;
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

/// Badges, logo, title, employer, location, quick facts and the salary box
/// with Apply.
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
    final posted = JobFormatter.posted(job.publishedAt, now);
    final closed =
        job.isClosed ||
        (DeadlineInfo.of(job.applicationDeadline, now)?.isClosed ?? false);
    final badges = [
      if (job.isNewAt(now))
        const _Badge(
          label: 'New',
          color: AppColors.success,
          background: AppColors.successLight,
        ),
      if (job.isFeatured)
        _Badge(
          label: job.featuredLabel ?? 'Featured',
          color: const Color(0xFFB45309),
          background: AppColors.warningLight,
        ),
      if (job.isSponsored)
        _Badge(
          label: job.sponsoredLabel ?? 'Sponsored',
          color: brand,
          background: _brandTint(context),
        ),
      if (closed)
        const _Badge(
          label: 'Not accepting applications',
          color: AppColors.error,
          background: AppColors.errorLight,
        ),
    ];
    final facts = [
      (
        Icons.work_outline_rounded,
        'Experience',
        JobFormatter.experience(job) ?? 'Any',
      ),
      (
        Icons.schedule_rounded,
        'Job type',
        JobFormatter.employmentType(job.employmentType),
      ),
      if (posted.isNotEmpty) (Icons.history_rounded, 'Posted', posted),
    ];

    return ApplySection(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badges.isNotEmpty) ...[
            Wrap(spacing: 6, runSpacing: 6, children: badges),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EmployerLogo(name: job.organization.name, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.organization.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (location != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < facts.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _FactTile(
                    icon: facts[i].$1,
                    label: facts[i].$2,
                    value: facts[i].$3,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
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
                        switch (job.salaryPeriod) {
                          SalaryPeriod.hourly => 'Hourly salary',
                          SalaryPeriod.daily => 'Daily salary',
                          SalaryPeriod.weekly => 'Weekly salary',
                          SalaryPeriod.monthly => 'Monthly salary',
                          SalaryPeriod.yearly => 'Yearly salary',
                          null => 'Salary',
                        },
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: brand,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        salary ?? 'Not disclosed',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (salary == null
                                    ? theme.textTheme.titleSmall
                                    : theme.textTheme.titleMedium)
                                ?.copyWith(fontWeight: FontWeight.w700),
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

/// Full-width amber (or red when closed) strip: "Apply before 30 Nov 2026 ·
/// 13 days left".
class JobDeadlineStrip extends StatelessWidget {
  const JobDeadlineStrip({super.key, required this.deadline});

  final DeadlineInfo deadline;

  @override
  Widget build(BuildContext context) {
    final color = deadline.color(context);
    final text = deadline.isClosed
        ? 'Applications closed on ${deadline.fullDateLabel}'
        : 'Apply before ${deadline.fullDateLabel}  ·  ${deadline.countdown}';
    return Container(
      width: double.infinity,
      color: deadline.background(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Icon(Icons.event_outlined, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Salary, experience, job type, posted date and deadline as label/value
/// rows.
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
    final salary = JobFormatter.salary(job);
    final posted = JobFormatter.posted(job.publishedAt, now);
    final rows = [
      (
        Icons.payments_outlined,
        'Salary',
        salary == null
            ? 'Not disclosed'
            : '$salary${JobFormatter.salaryPeriod(job.salaryPeriod)}',
        null,
      ),
      (
        Icons.work_outline_rounded,
        'Experience',
        JobFormatter.experience(job) ?? 'Any',
        null,
      ),
      (
        Icons.schedule_rounded,
        'Job type',
        JobFormatter.employmentType(job.employmentType),
        null,
      ),
      if (posted.isNotEmpty) (Icons.history_rounded, 'Posted', posted, null),
      if (deadline case final d?)
        (
          Icons.event_outlined,
          'Apply before',
          d.fullDateLabel,
          d.isUrgent || d.isClosed ? d.color(context) : null,
        ),
    ];

    return _Section(
      icon: Icons.info_outline_rounded,
      title: 'Job overview',
      child: Column(
        children: [
          for (final r in rows) ...[
            const ApplyRowDivider(),
            _InfoRow(icon: r.$1, label: r.$2, value: r.$3, valueColor: r.$4),
          ],
        ],
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
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in skills)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _brandTint(context),
                  borderRadius: BorderRadius.circular(100),
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
          for (final r in rows) ...[
            const ApplyRowDivider(),
            _InfoRow(label: r.$1, value: r.$2),
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
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            _EmployerLogo(name: job.organization.name, size: 44),
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
      ),
    );
  }
}

/// Full-width white section with an icon + title header, like the apply
/// flow's sections.
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ApplySection(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ApplySectionHeader(icon: icon, iconColor: iconColor, title: title),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

/// Initials in a tinted square, until real logos are loaded.
class _EmployerLogo extends StatelessWidget {
  const _EmployerLogo({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    // TODO: show the logo from organization.logoFileId.
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _brandTint(context),
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Text(
        _initials(name),
        style: TextStyle(
          color: _brand(context),
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Small bordered tile in the header: icon + label, value below.
class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 8, 10),
      decoration: BoxDecoration(
        border: Border.all(color: _border(context)),
        borderRadius: BorderRadius.circular(AppRadius.small + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: _brand(context)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// One row: optional icon, grey label on the left, bold value on the right.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  final IconData? icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: scheme.outline),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
