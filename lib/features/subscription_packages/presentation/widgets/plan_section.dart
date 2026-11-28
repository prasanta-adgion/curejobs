import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

/// A titled block on the plans screens. Sections are separated by a thick
/// grey band, the same pattern as `ProfileSection` and Job alerts.
class PlanSection extends StatelessWidget {
  const PlanSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.showBand = true,
  });

  final String title;
  final Widget child;

  /// Optional widget at the end of the title row, e.g. a "See all" link.
  final Widget? trailing;

  /// Draw the grey band above this section. Off for the first section.
  final bool showBand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: showBand
            ? Border(
                top: BorderSide(
                  color: colors.surfaceContainerHighest,
                  width: 8,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 28,
              child: Row(
                children: [
                  Expanded(child: SectionLabel(title)),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// Small grey uppercase heading, e.g. "YOUR CURRENT PLAN".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Small rounded tag, e.g. "Active", "Current", "Most popular".
class PlanTag extends StatelessWidget {
  const PlanTag({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
