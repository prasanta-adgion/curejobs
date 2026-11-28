import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/current_subscription.dart';
import 'plan_format.dart';
import 'plan_section.dart';

/// "Your current plan": name with Active tag, time left and the two limits.
class CurrentPlanSummary extends StatelessWidget {
  const CurrentPlanSummary({super.key, required this.subscription});

  final CurrentSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    final end = s.expiresAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlanHeader(subscription: s),
        if (!s.isFree && end != null) ...[
          const SizedBox(height: 14),
          _TimeLeftBar(subscription: s, end: end),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _LimitTile(
                label: 'Applications',
                value: PackageFormat.count(s.monthlyApplications),
                suffix: ' / month',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LimitTile(
                label: 'CV uploads',
                value: PackageFormat.count(s.maxResumes),
                suffix: ' max',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Icon, plan name, Active tag and validity line.
class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.subscription});

  final CurrentSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final s = subscription;
    final end = s.expiresAt;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: s.isFree
                ? colors.surfaceContainerHighest
                : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            s.isFree
                ? Icons.person_outline_rounded
                : Icons.workspace_premium_rounded,
            size: 22,
            color: s.isFree ? colors.onSurfaceVariant : AppColors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PackageFormat.shortName(s.package.name),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (end != null && s.isFree)
                Text(
                  'Valid till ${PackageFormat.date(end)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (s.isActive)
          PlanTag(
            label: 'Active',
            background: context.successContainer,
            foreground: context.successColor,
          ),
      ],
    );
  }
}

/// "18 days left · Renews 16 Dec 2026" with a progress bar.
class _TimeLeftBar extends StatelessWidget {
  const _TimeLeftBar({required this.subscription, required this.end});

  final CurrentSubscription subscription;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final s = subscription;
    final daysLeft = s.daysLeft() ?? 0;
    final totalDays = s.package.billingDurationDays;
    final progress = totalDays > 0
        ? (daysLeft / totalDays).clamp(0.0, 1.0)
        : 0.0;
    final ending = s.isEndingSoon;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: ending ? AppColors.warning : colors.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('$daysLeft days left', style: style)),
            Text(
              '${s.isAutoPayOn ? 'Renews' : 'Ends'} ${PackageFormat.date(end)}',
              style: style,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colors.surfaceContainerHighest,
            color: ending ? AppColors.warning : colors.primary,
          ),
        ),
      ],
    );
  }
}

/// Grey tile with one limit, e.g. "50 / month · Applications".
class _LimitTile extends StatelessWidget {
  const _LimitTile({
    required this.label,
    required this.value,
    required this.suffix,
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: suffix,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
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
