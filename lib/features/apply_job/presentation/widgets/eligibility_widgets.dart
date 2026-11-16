import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/application_eligibility.dart';

/// Colors for a pass / warning / fail tone, in light and dark mode.
class StatusTone {
  const StatusTone(this.foreground, this.background);

  final Color foreground;
  final Color background;

  static StatusTone of(BuildContext context, CheckStatus status) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = switch (status) {
      CheckStatus.pass => dark ? AppColors.successDark : AppColors.success,
      CheckStatus.fail => dark ? AppColors.errorDark : AppColors.error,
      _ => dark ? AppColors.warningDark : AppColors.warning,
    };
    final bg = dark
        ? base.withValues(alpha: 0.16)
        : switch (status) {
            CheckStatus.pass => AppColors.successLight,
            CheckStatus.fail => AppColors.errorLight,
            _ => AppColors.warningLight,
          };
    return StatusTone(base, bg);
  }
}

/// Banner at the top that says, in plain words, whether they can apply.
class EligibilityBanner extends StatelessWidget {
  const EligibilityBanner({super.key, required this.eligibility});

  final ApplicationEligibility eligibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final n = eligibility.questions.length;

    final (IconData icon, String title, String body, Color fg, Color bg) =
        switch (eligibility.status) {
          EligibilityStatus.notEligible => (
            Icons.block_rounded,
            "You can't apply to this job",
            'Check the items marked in red below.',
            StatusTone.of(context, CheckStatus.fail).foreground,
            StatusTone.of(context, CheckStatus.fail).background,
          ),
          EligibilityStatus.screeningRequired => (
            Icons.assignment_turned_in_outlined,
            'You can apply to this job',
            'Answer $n short ${n == 1 ? 'question' : 'questions'} from the recruiter to finish.',
            scheme.primary,
            scheme.primaryContainer.withValues(alpha: 0.5),
          ),
          _ => (
            Icons.assignment_turned_in_outlined,
            'You can apply to this job',
            'Review the details below, then send your application.',
            scheme.primary,
            scheme.primaryContainer.withValues(alpha: 0.5),
          ),
        };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: theme.textTheme.bodySmall?.copyWith(color: fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "3 Requirements met" / "4 Worth a look" counters.
class EligibilityCounts extends StatelessWidget {
  const EligibilityCounts({super.key, required this.eligibility});

  final ApplicationEligibility eligibility;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _CountTile(
        count: eligibility.passed.length,
        label: 'Requirements met',
        status: CheckStatus.pass,
      ),
      if (eligibility.warnings.isNotEmpty)
        _CountTile(
          count: eligibility.warnings.length,
          label: 'Worth a look',
          status: CheckStatus.warning,
        ),
      if (eligibility.failed.isNotEmpty)
        _CountTile(
          count: eligibility.failed.length,
          label: 'Not met',
          status: CheckStatus.fail,
        ),
    ];
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.count,
    required this.label,
    required this.status,
  });

  final int count;
  final String label;
  final CheckStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = StatusTone.of(context, status);
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: text.titleLarge?.copyWith(
              color: tone.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: text.labelSmall?.copyWith(color: tone.foreground)),
        ],
      ),
    );
  }
}

class CheckSectionTitle extends StatelessWidget {
  const CheckSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// One row of the checklist.
class EligibilityCheckTile extends StatelessWidget {
  const EligibilityCheckTile({
    super.key,
    required this.check,
    this.onAddSkills,
  });

  final EligibilityCheck check;
  final VoidCallback? onAddSkills;

  static const _maxSkillChips = 3;

  static const _titles = {
    'JOB_STATUS': 'Job status',
    'DEADLINE': 'Deadline',
    'EXPERIENCE': 'Experience',
    'SKILLS': 'Skills',
    'LOCATION': 'Location',
    'QUALIFICATION': 'Qualification',
    'EMPLOYMENT_TYPE': 'Employment type',
  };

  static const _icons = {
    'JOB_STATUS': Icons.work_outline_rounded,
    'DEADLINE': Icons.event_outlined,
    'EXPERIENCE': Icons.timeline_rounded,
    'SKILLS': Icons.psychology_outlined,
    'LOCATION': Icons.location_on_outlined,
    'QUALIFICATION': Icons.school_outlined,
    'EMPLOYMENT_TYPE': Icons.badge_outlined,
  };

  String get _title =>
      _titles[check.code] ??
      check.code
          .split('_')
          .map((w) => w.isEmpty ? w : w[0] + w.substring(1).toLowerCase())
          .join(' ');

  /// Friendlier text than the raw API message for long or vague ones.
  String _subtitle(List<String> skills) {
    if (skills.isNotEmpty) {
      final n = skills.length;
      return "$n required ${n == 1 ? "skill isn't" : "skills aren't"} on your profile";
    }
    if (check.code == 'EMPLOYMENT_TYPE') {
      return check.message.replaceFirst('Employment type:', '').trim().capitalized;
    }
    return check.message;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tone = StatusTone.of(context, check.status);
    final skills = check.missingSkills;
    final isPass = check.status == CheckStatus.pass;

    final icon = switch (check.status) {
      CheckStatus.pass => Icons.check_rounded,
      CheckStatus.fail => Icons.close_rounded,
      _ => _icons[check.code] ?? Icons.warning_amber_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: isPass
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: tone.background,
            child: Icon(icon, size: 17, color: tone.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isPass
                ? Text(check.message, style: theme.textTheme.bodyMedium)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(skills),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (skills.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SkillChips(skills: skills, max: _maxSkillChips),
                        if (onAddSkills != null)
                          TextButton.icon(
                            onPressed: onAddSkills,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.chevron_right_rounded, size: 18),
                            label: const Text('Add skills to profile'),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// First few skills as chips, then "+N more" that expands the rest.
class _SkillChips extends StatefulWidget {
  const _SkillChips({required this.skills, required this.max});

  final List<String> skills;
  final int max;

  @override
  State<_SkillChips> createState() => _SkillChipsState();
}

class _SkillChipsState extends State<_SkillChips> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hidden = widget.skills.length - widget.max;
    final shown = _expanded || hidden <= 0
        ? widget.skills
        : widget.skills.take(widget.max).toList();

    Widget chip(String label, {VoidCallback? onTap, bool accent = false}) =>
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: accent ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: accent ? FontWeight.w600 : null,
              ),
            ),
          ),
        );

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in shown) chip(s.capitalized),
        if (hidden > 0)
          chip(
            _expanded ? 'Show less' : '+$hidden more',
            accent: true,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
      ],
    );
  }
}

extension on String {
  String get capitalized => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
