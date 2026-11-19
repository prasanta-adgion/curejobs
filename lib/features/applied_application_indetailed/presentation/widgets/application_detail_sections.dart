import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../all_jobs/presentation/formatters/job_formatter.dart';
import '../../../apply_job/presentation/widgets/apply_flow_widgets.dart';
import '../../../applied_application/presentation/models/application_ui_model.dart';
import '../../domain/entities/application_detail.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "14 Oct 2026"
String formatDate(DateTime d) {
  final l = d.toLocal();
  return '${l.day} ${_months[l.month - 1]} ${l.year}';
}

/// "14 Oct 2026, 4:06 PM"
String formatDateTime(DateTime d) {
  final l = d.toLocal();
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final m = l.minute.toString().padLeft(2, '0');
  return '${formatDate(l)}, $h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
}

Color _brand(BuildContext c) => Theme.of(c).brightness == Brightness.dark
    ? AppColors.darkPrimary
    : AppColors.primary;

Color _brandTint(BuildContext c) => Theme.of(c).brightness == Brightness.dark
    ? AppColors.darkPrimary.withValues(alpha: 0.16)
    : AppColors.primaryLight;

IconData _statusIcon(ApplicationStatus s) => switch (s) {
  ApplicationStatus.applied => Icons.send_outlined,
  ApplicationStatus.underReview => Icons.visibility_outlined,
  ApplicationStatus.shortlisted => Icons.star_outline_rounded,
  ApplicationStatus.selected => Icons.check_circle_outline_rounded,
  ApplicationStatus.rejected => Icons.cancel_outlined,
  ApplicationStatus.withdrawn => Icons.undo_rounded,
};

/// Section with an icon + title header, like the job details sections.
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ApplySection(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ApplySectionHeader(
            icon: icon,
            iconColor: _brand(context),
            title: title,
            trailing: trailing,
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Logo, title, hospital, location and status chips.
class ApplicationDetailHeader extends StatelessWidget {
  const ApplicationDetailHeader({super.key, required this.detail});

  final ApplicationDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final job = detail.job;
    final status = detail.status.colors(context);
    final location = JobFormatter.location(job);

    return ApplySection(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Logo(name: job.organization.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.organization.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (location != null && location.isNotEmpty) ...[
                      const SizedBox(height: 4),
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Chip(
                icon: _statusIcon(detail.status),
                label: detail.status.label,
                color: status.fg,
                background: status.bg,
              ),
              if (job.isClosed)
                _Chip(
                  icon: Icons.timer_off_outlined,
                  label: 'Job closed',
                  color: scheme.onSurfaceVariant,
                  background: ApplyFlowColors.page(context),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final initials = words.take(2).map((w) => w[0].toUpperCase()).join();
    // TODO: show the logo from organization.logoFileId.
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _brandTint(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: _brand(context),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Yellow strip under the header when the job stopped taking applications.
class JobClosedStrip extends StatelessWidget {
  const JobClosedStrip({super.key, required this.stillActive});

  /// The application is still being reviewed.
  final bool stillActive;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? AppColors.warningDark : const Color(0xFFB45309);
    return Container(
      width: double.infinity,
      color: dark ? fg.withValues(alpha: 0.16) : AppColors.warningLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stillActive
                  ? 'This job no longer takes applications. Yours is still '
                        'being reviewed.'
                  : 'This job no longer takes applications.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline of status changes, with a pending step while still active.
class ApplicationProgressSection extends StatelessWidget {
  const ApplicationProgressSection({super.key, required this.detail});

  final ApplicationDetail detail;

  @override
  Widget build(BuildContext context) {
    final steps = [
      for (final h in detail.history) (h.status.label, formatDateTime(h.at)),
      if (detail.history.isEmpty)
        (ApplicationStatus.applied.label, formatDateTime(detail.appliedAt)),
    ];
    final pending = detail.status.isActive;

    return _Section(
      icon: Icons.route_outlined,
      title: 'Application progress',
      child: Column(
        children: [
          const ApplyRowDivider(),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            _TimelineStep(
              title: steps[i].$1,
              subtitle: steps[i].$2,
              done: true,
              isLast: i == steps.length - 1 && !pending,
              lineDone: i < steps.length - 1,
            ),
          if (pending)
            const _TimelineStep(
              title: 'Hospital decision',
              subtitle: 'Pending',
              done: false,
              isLast: true,
              lineDone: false,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.isLast,
    required this.lineDone,
  });

  final String title;
  final String subtitle;
  final bool done;
  final bool isLast;
  final bool lineDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = _brand(context);
    final idle = scheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 14,
            child: Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? brand : null,
                    border: done ? null : Border.all(color: idle, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: lineDone ? brand : idle,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                      color: done ? null : scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Salary, experience, job type, applied date and a link to the job.
class ApplicationJobOverviewSection extends StatelessWidget {
  const ApplicationJobOverviewSection({
    super.key,
    required this.detail,
    required this.onViewJob,
  });

  final ApplicationDetail detail;
  final VoidCallback onViewJob;

  @override
  Widget build(BuildContext context) {
    final job = detail.job;
    final salary = JobFormatter.salary(job);
    final rows = [
      (
        Icons.payments_outlined,
        'Salary',
        salary == null
            ? 'Not disclosed'
            : '$salary${JobFormatter.salaryPeriod(job.salaryPeriod)}',
      ),
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
      (Icons.event_outlined, 'Applied on', formatDate(detail.appliedAt)),
      if (detail.withdrawnAt case final w?)
        (Icons.undo_rounded, 'Withdrawn on', formatDate(w)),
    ];

    return _Section(
      icon: Icons.info_outline_rounded,
      title: 'Job overview',
      child: Column(
        children: [
          for (final r in rows) ...[
            const ApplyRowDivider(),
            _InfoRow(icon: r.$1, label: r.$2, value: r.$3),
          ],
          const ApplyRowDivider(),
          _LinkRow(
            label: 'View job',
            icon: Icons.chevron_right_rounded,
            onTap: onViewJob,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.outline),
          const SizedBox(width: 10),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = _brand(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 11),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: brand, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(icon, size: 20, color: brand),
          ],
        ),
      ),
    );
  }
}

/// Screening checks: the first three, the rest behind "Show all".
class EligibilitySection extends StatefulWidget {
  const EligibilitySection({super.key, required this.screening});

  final ScreeningResult screening;

  @override
  State<EligibilitySection> createState() => _EligibilitySectionState();
}

class _EligibilitySectionState extends State<EligibilitySection> {
  static const _preview = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.screening;
    // Show warnings and failures first so they aren't hidden.
    final checks = [...s.checks]
      ..sort((a, b) => b.status.index.compareTo(a.status.index));
    final visible = _expanded ? checks : checks.take(_preview).toList();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return _Section(
      icon: Icons.verified_user_outlined,
      title: 'Eligibility check',
      trailing: _Chip(
        icon: null,
        label: s.passed ? 'Passed' : 'Not passed',
        color: s.passed
            ? (dark ? AppColors.successDark : AppColors.success)
            : (dark ? AppColors.errorDark : AppColors.error),
        background: s.passed
            ? (dark
                  ? AppColors.successDark.withValues(alpha: 0.16)
                  : AppColors.successLight)
            : (dark
                  ? AppColors.errorDark.withValues(alpha: 0.16)
                  : AppColors.errorLight),
      ),
      child: Column(
        children: [
          for (final c in visible) ...[
            const ApplyRowDivider(),
            _CheckRow(check: c),
          ],
          if (checks.length > _preview) ...[
            const ApplyRowDivider(),
            _LinkRow(
              label: _expanded
                  ? 'Show less'
                  : 'Show all ${checks.length} checks',
              icon: _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check});

  final ScreeningCheck check;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color) = switch (check.status) {
      CheckStatus.pass => (
        Icons.check_circle_outline_rounded,
        dark ? AppColors.successDark : AppColors.success,
      ),
      CheckStatus.warning => (
        Icons.warning_amber_rounded,
        dark ? AppColors.warningDark : const Color(0xFFB45309),
      ),
      CheckStatus.fail => (
        Icons.cancel_outlined,
        dark ? AppColors.errorDark : AppColors.error,
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              check.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Screening questions and the candidate's answers.
class ScreeningAnswersSection extends StatelessWidget {
  const ScreeningAnswersSection({super.key, required this.answers});

  final List<ScreeningAnswer> answers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _Section(
      icon: Icons.quiz_outlined,
      title: 'Your answers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final a in answers) ...[
            const ApplyRowDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.question,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.answer,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The resume sent with the application.
class SubmittedResumeSection extends StatelessWidget {
  const SubmittedResumeSection({
    super.key,
    required this.resume,
    required this.onView,
  });

  final SubmittedResume resume;

  /// Null when there's no generated file to open.
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final pdf = dark ? AppColors.errorDark : AppColors.error;
    final template = resume.templateKey;

    return _Section(
      icon: Icons.description_outlined,
      title: 'Submitted resume',
      child: Column(
        children: [
          const ApplyRowDivider(),
          InkWell(
            onTap: onView,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: dark
                          ? pdf.withValues(alpha: 0.16)
                          : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 20,
                      color: pdf,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resume.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (template != null && template.isNotEmpty)
                          Text(
                            '${template[0].toUpperCase()}'
                            '${template.substring(1)} template',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onView != null)
                    Text(
                      'View',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _brand(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
