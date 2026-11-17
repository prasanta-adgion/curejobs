import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Shared look for the apply flow: purple app bar with a step tracker,
/// full-width white sections on a light grey page, and a white bottom bar.
class ApplyFlowColors {
  ApplyFlowColors._();

  static bool _dark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  /// Grey page behind the sections (shows as the gaps between them).
  static Color page(BuildContext c) =>
      _dark(c) ? AppColors.darkBackground : AppColors.lightSurfaceSecondary;

  /// White section / bottom bar.
  static Color section(BuildContext c) =>
      _dark(c) ? AppColors.darkSurface : AppColors.lightSurface;

  /// Thin line between rows inside a section.
  static Color divider(BuildContext c) =>
      _dark(c) ? AppColors.darkDivider : AppColors.lightSurfaceSecondary;

  static Color appBar(BuildContext c) =>
      _dark(c) ? AppColors.primaryDark : AppColors.primary;
}

enum ApplyStep {
  eligibility('Eligibility'),
  questions('Questions'),
  cv('CV'),
  review('Review');

  const ApplyStep(this.label);

  final String label;
}

/// Purple app bar with title, subtitle and the 4-step tracker.
class ApplyStepAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ApplyStepAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.step,
    this.backgroundColor,
    this.showBack = true,
    this.actions,
  });

  final String title;
  final String? subtitle;

  /// Current step; null hides the tracker.
  final ApplyStep? step;
  final Color? backgroundColor;
  final bool showBack;
  final List<Widget>? actions;

  static const _subtitleColor = Color(0xFFD9D6FA);

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (step == null ? 0 : 58));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = step;

    return AppBar(
      backgroundColor: backgroundColor ?? ApplyFlowColors.appBar(context),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: showBack,
      titleSpacing: showBack ? 0 : 16,
      actions: actions,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle case final s? when s.isNotEmpty)
            Text(
              s,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: _subtitleColor),
            ),
        ],
      ),
      bottom: current == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 10),
                child: Row(
                  children: [
                    for (final s in ApplyStep.values)
                      Expanded(
                        child: _StepDot(
                          step: s,
                          current: current,
                          labelStyle: theme.textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// One numbered step in the app bar tracker: a circle (tick when done,
/// filled white when current, outlined when upcoming), lines joining it to
/// its neighbours, and the step name below.
class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.current,
    required this.labelStyle,
  });

  final ApplyStep step;
  final ApplyStep current;
  final TextStyle? labelStyle;

  static const _size = 26.0;

  @override
  Widget build(BuildContext context) {
    final appBar = ApplyFlowColors.appBar(context);
    final done = step.index < current.index;
    final isCurrent = step == current;
    final dim = Colors.white.withValues(alpha: 0.35);

    Widget line(bool active) => Expanded(
      child: Container(height: 2, color: active ? Colors.white : dim),
    );

    return Column(
      children: [
        SizedBox(
          height: _size,
          child: Row(
            children: [
              step.index == 0
                  ? const Spacer()
                  : line(step.index <= current.index),
              Container(
                width: _size,
                height: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done || isCurrent ? Colors.white : appBar,
                  border: Border.all(
                    color: done || isCurrent
                        ? Colors.white
                        : ApplyStepAppBar._subtitleColor,
                    width: 1.5,
                  ),
                ),
                child: done
                    ? Icon(Icons.check_rounded, size: 16, color: appBar)
                    : Text(
                        '${step.index + 1}',
                        style: labelStyle?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCurrent
                              ? appBar
                              : ApplyStepAppBar._subtitleColor,
                        ),
                      ),
              ),
              step.index == ApplyStep.values.length - 1
                  ? const Spacer()
                  : line(step.index < current.index),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          step.label,
          style: labelStyle?.copyWith(
            fontSize: 11,
            color: isCurrent || done
                ? Colors.white
                : ApplyStepAppBar._subtitleColor,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// Full-width white block. Stack these with [ApplySectionGap] between.
class ApplySection extends StatelessWidget {
  const ApplySection({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 14),
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color ?? ApplyFlowColors.section(context),
      padding: padding,
      child: child,
    );
  }
}

class ApplySectionGap extends StatelessWidget {
  const ApplySectionGap({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 8);
}

/// Icon + title row at the top of a section, with an optional action.
class ApplySectionHeader extends StatelessWidget {
  const ApplySectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// Thin line between rows inside a section.
class ApplyRowDivider extends StatelessWidget {
  const ApplyRowDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: ApplyFlowColors.divider(context));
}

/// White strip pinned to the bottom with the main button.
class ApplyBottomBar extends StatelessWidget {
  const ApplyBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ApplyFlowColors.section(context),
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: child,
      ),
    );
  }
}

/// Full-width purple primary button used at the bottom of each step.
class ApplyPrimaryButton extends StatelessWidget {
  const ApplyPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: ApplyFlowColors.appBar(context),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    return icon == null
        ? FilledButton(onPressed: onPressed, style: style, child: Text(label))
        : FilledButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 18),
            label: Text(label),
          );
  }
}
