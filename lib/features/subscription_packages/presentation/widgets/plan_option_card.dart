import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/subscription_package.dart';
import 'plan_format.dart';
import 'plan_section.dart';

/// Selectable plan card: radio, name, price and up to three highlights.
/// The recommended plan gets a "Most popular" badge on its top edge.
class PlanOptionCard extends StatelessWidget {
  const PlanOptionCard({
    super.key,
    required this.package,
    required this.selected,
    required this.recommended,
    required this.isCurrent,
    required this.onTap,
  });

  final SubscriptionPackage package;
  final bool selected;
  final bool recommended;
  final bool isCurrent;
  final VoidCallback onTap;

  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showBadge = recommended && !isCurrent;

    final card = Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_radius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CardHeader(
                    package: package,
                    selected: selected,
                    isCurrent: isCurrent,
                  ),
                  _Highlights(items: planHighlights(package)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: showBadge ? 10 : 0, bottom: 12),
      child: showBadge
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                card,
                const Positioned(top: -11, left: 16, child: _PopularBadge()),
              ],
            )
          : card,
    );
  }

  /// Up to three short selling points: limits first, then features.
  static List<String> planHighlights(SubscriptionPackage p) {
    final apps = p.monthlyApplications;
    final cvs = p.maxResumes;
    return [
      if (apps != null) '${PackageFormat.count(apps)} applications / month',
      if (cvs != null) '${PackageFormat.count(cvs)} CV uploads',
      for (final f in PackageFeature.displayed.entries)
        if (p.has(f.key)) f.value,
    ].take(3).toList();
  }
}

/// Radio, name with "Current" tag, and price.
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.package,
    required this.selected,
    required this.isCurrent,
  });

  final SubscriptionPackage package;
  final bool selected;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final p = package;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _PlanRadio(selected: selected),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                PackageFormat.shortName(p.name),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isCurrent)
                PlanTag(
                  label: 'Current',
                  background: colors.surfaceContainerHighest,
                  foreground: colors.onSurfaceVariant,
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              p.isFree
                  ? 'Free'
                  : PackageFormat.price(
                      p.amountMinor,
                      currency: p.amountCurrency,
                    ),
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              p.isFree
                  ? 'forever'
                  : 'for ${PackageFormat.duration(p.billingDurationDays)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Ticked list under the card header, split off by a thin line.
class _Highlights extends StatelessWidget {
  const _Highlights({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Divider(height: 1, color: colors.outlineVariant),
        const SizedBox(height: 4),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: context.successColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
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

class _PlanRadio extends StatelessWidget {
  const _PlanRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.primary : Colors.transparent,
        border: Border.all(
          color: selected ? colors.primary : colors.outline,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 15, color: colors.surface)
          : null,
    );
  }
}

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'MOST POPULAR',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
