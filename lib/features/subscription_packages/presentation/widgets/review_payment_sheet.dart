import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/subscription_package.dart';
import 'plan_format.dart';

/// "Review & pay" bottom sheet shown before Razorpay opens, so the user
/// sees the amount and the renewal terms before paying.
///
/// Resolves to `true` only when the user taps Pay.
abstract final class ReviewPaymentSheet {
  static Future<bool> show(
    BuildContext context,
    SubscriptionPackage package,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ReviewPaymentBody(package: package),
    );
    return confirmed ?? false;
  }
}

class _ReviewPaymentBody extends StatelessWidget {
  const _ReviewPaymentBody({required this.package});

  final SubscriptionPackage package;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final p = package;
    final price = PackageFormat.price(
      p.amountMinor,
      currency: p.amountCurrency,
    );
    final period = PackageFormat.duration(p.billingDurationDays);
    final renewsOn = PackageFormat.date(
      DateTime.now().add(Duration(days: p.billingDurationDays)),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Review & pay',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _PlanSummaryTile(package: p, period: period),
            const SizedBox(height: 16),
            _TotalRow(price: price),
            const SizedBox(height: 16),
            _TermsBox(price: price, period: period, renewsOn: renewsOn),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              icon: const Icon(Icons.lock_outline_rounded, size: 18),
              label: Text('Pay $price securely'),
            ),
            const SizedBox(height: 10),
            Text(
              'Payments are processed by Razorpay',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanSummaryTile extends StatelessWidget {
  const _PlanSummaryTile({required this.package, required this.period});

  final SubscriptionPackage package;
  final String period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PackageFormat.shortName(package.name),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Valid for $period',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Change', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: context.colors.onSurface,
      fontWeight: FontWeight.w700,
    );
    return Row(
      children: [
        Expanded(child: Text('Pay today', style: style)),
        Text(price, style: style),
      ],
    );
  }
}

/// Renewal terms in plain words, shown before the user pays.
class _TermsBox extends StatelessWidget {
  const _TermsBox({
    required this.price,
    required this.period,
    required this.renewsOn,
  });

  final String price;
  final String period;
  final String renewsOn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _TermLine(
            icon: Icons.autorenew_rounded,
            text:
                'Renews automatically at $price every $period '
                '(next on $renewsOn).',
          ),
          const SizedBox(height: 10),
          const _TermLine(
            icon: Icons.check_rounded,
            text: 'Turn off auto-pay anytime from the Plans screen.',
          ),
        ],
      ),
    );
  }
}

class _TermLine extends StatelessWidget {
  const _TermLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurface, height: 1.45),
          ),
        ),
      ],
    );
  }
}
