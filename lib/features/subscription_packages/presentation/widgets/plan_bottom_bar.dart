import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/subscription_package.dart';
import 'plan_format.dart';

/// Sticky bar under the plans list: the selected plan and its price, the
/// main button and one honest line about renewal.
class PlanBottomBar extends StatelessWidget {
  const PlanBottomBar({
    super.key,
    required this.package,
    required this.isCurrent,
    required this.onPressed,
    this.isDowngradeBlocked = false,
    this.busy = false,
  });

  final SubscriptionPackage package;
  final bool isCurrent;
  final VoidCallback onPressed;

  /// The user is on a paid plan and this is a free one: switching is not
  /// allowed, so the button is disabled with a short explanation.
  final bool isDowngradeBlocked;

  /// A payment is running: the button is disabled and shows a spinner.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final note = _note;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!package.isFree && !isCurrent) ...[
              _PriceRow(package: package),
              const SizedBox(height: 10),
            ],
            _buildButton(colors),
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(
                note,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _name => PackageFormat.shortName(package.name);

  String? get _note {
    if (isDowngradeBlocked) {
      return 'You already enjoy everything in $_name. '
          'You can switch once your paid plan ends.';
    }
    if (package.isFree || isCurrent) return null;
    return 'Renews every ${PackageFormat.duration(package.billingDurationDays)}'
        ' · Cancel anytime';
  }

  Widget _buildButton(ColorScheme colors) {
    // No action possible: the user already has this plan, or a paid user
    // picked a free one. Show a quiet outlined button.
    if (isCurrent || isDowngradeBlocked) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          disabledForegroundColor: colors.onSurfaceVariant,
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Text(
          isCurrent ? "You're on $_name" : 'Your paid plan is active',
        ),
      );
    }

    // Any plan the user can switch to, free or paid, gets the main button.
    final canPress = (package.isFree || package.purchaseAvailable) && !busy;
    return FilledButton(
      onPressed: canPress ? onPressed : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      child: busy
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.white,
              ),
            )
          : Text('Continue with $_name'),
    );
  }
}

/// "Pro · 1 month          ₹499"
class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.package});

  final SubscriptionPackage package;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final p = package;
    return Row(
      children: [
        Expanded(
          child: Text(
            '${PackageFormat.shortName(p.name)} · '
            '${PackageFormat.duration(p.billingDurationDays)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          PackageFormat.price(p.amountMinor, currency: p.amountCurrency),
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
