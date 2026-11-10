import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../shared/widgets/profile_section.dart';

/// Application counts by hiring stage.
///
/// UI-only for now; will be filled from the API later.
class ApplicationCounts {
  const ApplicationCounts({
    this.applied = 0,
    this.underReview = 0,
    this.shortlisted = 0,
    this.selected = 0,
    this.rejected = 0,
    this.withdrawn = 0,
  });

  final int applied;
  final int underReview;
  final int shortlisted;
  final int selected;
  final int rejected;
  final int withdrawn;

  /// Sample values for the mockup.
  static const sample = ApplicationCounts(
    applied: 1,
    underReview: 1,
    withdrawn: 4,
  );
}

/// "My applications": the hiring stages as a connected pipeline, with a
/// plain-language status line underneath.
class MyApplicationsSection extends StatelessWidget {
  const MyApplicationsSection({
    super.key,
    required this.counts,
    this.onViewAll,
    this.showDivider = false,
  });

  final ApplicationCounts counts;
  final VoidCallback? onViewAll;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final stages = [
      _Stage('Applied', counts.applied),
      _Stage('In review', counts.underReview),
      _Stage('Shortlisted', counts.shortlisted),
      _Stage('Selected', counts.selected, icon: Icons.emoji_events_outlined),
    ];

    // Furthest stage that has at least one application; -1 when none.
    final reached = stages.lastIndexWhere((s) => s.count > 0);

    return ProfileSection(
      title: 'My applications',
      showDivider: showDivider,
      action: SectionAction(
        label: 'View all',
        icon: Icons.chevron_right,
        onPressed: onViewAll,
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          _Pipeline(stages: stages, reached: reached),
          const SizedBox(height: 14),
          _StatusBar(counts: counts),
        ],
      ),
    );
  }
}

class _Stage {
  const _Stage(this.label, this.count, {this.icon});

  final String label;
  final int count;

  /// Shown instead of "0" so an empty final step reads as a goal.
  final IconData? icon;
}

class _Pipeline extends StatelessWidget {
  const _Pipeline({required this.stages, required this.reached});

  final List<_Stage> stages;
  final int reached;

  static const _node = 36.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final slot = constraints.maxWidth / stages.length;
        final start = slot / 2;
        final full = slot * (stages.length - 1);
        final filled = reached <= 0 ? 0.0 : slot * reached;

        return Stack(
          children: [
            Positioned(
              top: _node / 2 - 1,
              left: start,
              width: full,
              height: 2,
              child: ColoredBox(color: scheme.outlineVariant),
            ),
            Positioned(
              top: _node / 2 - 1,
              left: start,
              width: filled,
              height: 2,
              child: ColoredBox(color: scheme.primary),
            ),
            Row(
              children: [
                for (var i = 0; i < stages.length; i++)
                  Expanded(
                    child: _StageNode(
                      stage: stages[i],
                      state: _stateFor(i),
                      size: _node,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  _NodeState _stateFor(int i) {
    if (stages[i].count == 0) {
      return i < reached ? _NodeState.passed : _NodeState.upcoming;
    }
    return i == reached ? _NodeState.current : _NodeState.done;
  }
}

enum _NodeState { done, current, passed, upcoming }

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.stage,
    required this.state,
    required this.size,
  });

  final _Stage stage;
  final _NodeState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (Color fill, Color fg, Color ring) = switch (state) {
      _NodeState.done => (scheme.primary, scheme.onPrimary, scheme.primary),
      _NodeState.current => (
        scheme.primaryContainer,
        scheme.primary,
        scheme.primary,
      ),
      _NodeState.passed => (
        scheme.surface,
        scheme.onSurfaceVariant,
        scheme.primary,
      ),
      _NodeState.upcoming => (
        scheme.surface,
        scheme.outline,
        scheme.outlineVariant,
      ),
    };
    final active = state == _NodeState.done || state == _NodeState.current;
    final isSelected = stage.icon != null && stage.count > 0;

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.success : fill,
            border: Border.all(
              color: isSelected ? AppColors.success : ring,
              width: 1.5,
            ),
          ),
          child: stage.icon != null && stage.count == 0
              ? Icon(stage.icon, size: 17, color: fg)
              : Text(
                  '${stage.count}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isSelected ? AppColors.white : fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          stage.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: active ? scheme.onSurface : scheme.outline,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.counts});

  final ApplicationCounts counts;

  String get _message {
    if (counts.selected > 0) {
      return counts.selected == 1
          ? "You've been selected for 1 job"
          : "You've been selected for ${counts.selected} jobs";
    }
    if (counts.shortlisted > 0) {
      return _plural(counts.shortlisted, 'application is', 'applications are') +
          ' shortlisted';
    }
    if (counts.underReview > 0) {
      return _plural(counts.underReview, 'application is', 'applications are') +
          ' being reviewed';
    }
    if (counts.applied > 0) {
      return _plural(counts.applied, 'application', 'applications') +
          ' waiting for review';
    }
    return 'Apply to a job to track it here';
  }

  static String _plural(int n, String one, String many) =>
      '$n ${n == 1 ? one : many}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final closed = [
      if (counts.withdrawn > 0) '${counts.withdrawn} withdrawn',
      if (counts.rejected > 0) '${counts.rejected} not selected',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
          if (closed.isNotEmpty)
            Text(
              closed,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.outline,
              ),
            ),
        ],
      ),
    );
  }
}
