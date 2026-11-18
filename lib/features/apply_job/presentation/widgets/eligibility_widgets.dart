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

  /// Darker amber for text on the light amber background (better contrast).
  static Color text(BuildContext context, CheckStatus status) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (!dark && status == CheckStatus.warning) return const Color(0xFFB45309);
    return of(context, status).foreground;
  }
}

const _checkTitles = {
  'JOB_STATUS': 'Job status',
  'DEADLINE': 'Deadline',
  'EXPERIENCE': 'Experience',
  'SKILLS': 'Skills',
  'LOCATION': 'Location',
  'QUALIFICATION': 'Qualification',
  'EMPLOYMENT_TYPE': 'Job type',
};

/// Human name for a check code, e.g. `SKILLS` → "Skills".
String checkTitle(String code) =>
    _checkTitles[code] ??
    code
        .split('_')
        .map((w) => w.isEmpty ? w : w[0] + w.substring(1).toLowerCase())
        .join(' ');

/// Big centred result: icon, "You can apply to this job", one plain
/// sentence, and a bar with one block per requirement.
class EligibilityResult extends StatelessWidget {
  const EligibilityResult({super.key, required this.eligibility});

  final ApplicationEligibility eligibility;

  String _sentence() {
    final e = eligibility;
    final total = e.passed.length + e.warnings.length + e.failed.length;
    if (!e.status.canApply) {
      final first = e.failed.isEmpty ? null : e.failed.first.message;
      return first ?? 'This job is not open to your profile right now.';
    }
    final met = 'You meet ${e.passed.length} of $total requirements.';
    return switch (e.warnings.length) {
      0 => '$met Everything looks good.',
      1 => '$met 1 is worth a quick look.',
      final n => '$met $n are worth a quick look.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final e = eligibility;
    final canApply = e.status.canApply;
    final tone = StatusTone.of(
      context,
      canApply ? CheckStatus.pass : CheckStatus.fail,
    );
    final blocks = [
      for (final _ in e.passed) CheckStatus.pass,
      for (final _ in e.warnings) CheckStatus.warning,
      for (final _ in e.failed) CheckStatus.fail,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: tone.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              canApply ? Icons.check_rounded : Icons.close_rounded,
              size: 32,
              color: tone.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            canApply
                ? 'You can apply to this job'
                : "You can't apply to this job yet",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _sentence(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (blocks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < blocks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: StatusTone.of(context, blocks[i]).foreground,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _Legend(
                  status: CheckStatus.pass,
                  label: '${e.passed.length} met',
                ),
                if (e.warnings.isNotEmpty)
                  _Legend(
                    status: CheckStatus.warning,
                    label: '${e.warnings.length} to check',
                  ),
                if (e.failed.isNotEmpty)
                  _Legend(
                    status: CheckStatus.fail,
                    label: '${e.failed.length} not met',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.status, required this.label});

  final CheckStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: StatusTone.of(context, status).foreground,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
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

/// Small rounded status label: "Met", "To check", "Not met".
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final CheckStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = StatusTone.of(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        switch (status) {
          CheckStatus.pass => 'Met',
          CheckStatus.fail => 'Not met',
          _ => 'To check',
        },
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: StatusTone.text(context, status),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// One row of the checklist: status circle, title, plain explanation and a
/// status pill on the right.
class EligibilityCheckTile extends StatelessWidget {
  const EligibilityCheckTile({
    super.key,
    required this.check,
    this.onAddSkills,
  });

  final EligibilityCheck check;
  final VoidCallback? onAddSkills;

  static const _maxSkillChips = 3;

  String get _title => checkTitle(check.code);

  /// Friendlier text than the raw API message for long or vague ones.
  String _subtitle(List<String> skills) {
    if (skills.isNotEmpty) {
      final n = skills.length;
      return "$n required ${n == 1 ? "skill isn't" : "skills aren't"} on your "
          'profile yet. Add the ones you know.';
    }
    if (check.code == 'EMPLOYMENT_TYPE') {
      return check.message
          .replaceFirst('Employment type:', '')
          .trim()
          .capitalized;
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
      _ => Icons.priority_high_rounded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isPass ? 13 : 15,
            backgroundColor: tone.background,
            child: Icon(icon, size: isPass ? 15 : 17, color: tone.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(status: check.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(skills),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SkillChips(
                    skills: skills,
                    max: _maxSkillChips,
                    color: StatusTone.text(context, check.status),
                  ),
                  if (onAddSkills != null) ...[
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: onAddSkills,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add skills to profile'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// First few skills as outlined chips, then "+N more" that expands the rest.
class _SkillChips extends StatefulWidget {
  const _SkillChips({
    required this.skills,
    required this.max,
    required this.color,
  });

  final List<String> skills;
  final int max;
  final Color color;

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

    Widget chip(String label, {VoidCallback? onTap, bool accent = false}) {
      final color = accent ? scheme.primary : widget.color;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in shown) chip(s.capitalized),
        if (hidden > 0)
          chip(
            _expanded ? 'Show less' : '+$hidden more',
            accent: true,
            onTap: () {
              if (!mounted) return;
              setState(() => _expanded = !_expanded);
            },
          ),
      ],
    );
  }
}

/// "What happens next": the remaining apply steps as a short numbered list.
class ApplyNextSteps extends StatelessWidget {
  const ApplyNextSteps({super.key, required this.questionCount});

  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final n = questionCount;
    // Numbers match the step tracker in the app bar.
    final steps = [
      if (n > 0)
        (
          'Answer $n short ${n == 1 ? 'question' : 'questions'}',
          'From the recruiter',
          2,
        ),
      ('Choose your CV', 'Use a saved CV or upload a new one', 3),
      ('Review and send', 'Check everything before it goes', 4),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 26,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: scheme.primaryContainer,
                        child: Text(
                          '${steps[i].$3}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: scheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].$1,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          steps[i].$2,
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
          ),
      ],
    );
  }
}

extension on String {
  String get capitalized =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
