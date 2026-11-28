import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/current_subscription.dart';
import 'plan_format.dart';
import 'plan_section.dart';

/// Billing details under a paid plan: auto-pay status, next charge and a
/// plainly visible "Turn off auto-pay" button.
class AutoPaySection extends StatelessWidget {
  const AutoPaySection({
    super.key,
    required this.subscription,
    required this.onTurnOff,
    this.busy = false,
  });

  final CurrentSubscription subscription;
  final VoidCallback onTurnOff;

  /// The cancel request is running.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final s = subscription;
    final on = s.isAutoPayOn;
    final end = s.expiresAt;
    final endText = end == null ? '' : PackageFormat.date(end);
    final price = PackageFormat.price(
      s.package.amountMinor,
      currency: s.package.amountCurrency,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Divider(height: 1, color: colors.outlineVariant),
        _BillingRow(
          title: 'Auto-pay',
          subtitle: on
              ? '$price will be charged on $endText'
              : "You won't be charged again",
          trailing: PlanTag(
            label: on ? 'On' : 'Off',
            background: on
                ? context.successContainer
                : colors.surfaceContainerHighest,
            foreground: on ? context.successColor : colors.onSurfaceVariant,
          ),
        ),
        if (end != null) ...[
          Divider(height: 1, color: colors.outlineVariant),
          _BillingRow(title: on ? 'Renews on' : 'Ends on', subtitle: endText),
        ],
        if (s.canCancelAutoRenew) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: busy ? null : onTurnOff,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: colors.onSurface,
              side: BorderSide(color: colors.outlineVariant),
            ),
            child: busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Text('Turn off auto-pay'),
          ),
          const SizedBox(height: 8),
          Text(
            'You keep your plan until $endText. No further charges.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BillingRow extends StatelessWidget {
  const _BillingRow({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// "Turn off auto-pay?" bottom sheet.
///
/// Spells out exactly what happens and gives both choices equal weight,
/// so the user never feels pushed. Resolves to `true` only on "Turn off".
abstract final class CancelAutoPaySheet {
  static Future<bool> show(
    BuildContext context,
    CurrentSubscription subscription,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _CancelAutoPaySheetBody(subscription: subscription),
    );
    return confirmed ?? false;
  }
}

class _CancelAutoPaySheetBody extends StatelessWidget {
  const _CancelAutoPaySheetBody({required this.subscription});

  final CurrentSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final name = PackageFormat.shortName(subscription.package.name);
    final end = subscription.expiresAt;
    final endText = end == null
        ? 'the end of this period'
        : PackageFormat.date(end);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Turn off auto-pay?',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Here's exactly what happens. No surprises.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _Consequence(
              title: 'Keep all $name benefits till $endText',
              detail: 'Nothing changes until your current period ends.',
            ),
            const _Consequence(
              title: 'No more charges',
              detail: 'Nothing is deducted on renewal, nothing to refund.',
            ),
            const _Consequence(
              title: 'Then you move to Free',
              detail: 'Your profile, CVs and applications stay safe.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You can buy $name again anytime from the Plans screen.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onSurface,
                      side: BorderSide(color: colors.outlineVariant),
                    ),
                    child: const Text('Turn off'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Keep auto-pay'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One ticked line in the cancel sheet: bold title, muted detail.
class _Consequence extends StatelessWidget {
  const _Consequence({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_rounded, size: 16, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail,
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
