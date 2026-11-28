import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/package_request.dart';
import '../../domain/entities/subscription_package.dart';
import 'plan_format.dart';

/// Sticky bar under the plans list: the selected plan and its price, the
/// main button and one honest line about what happens next.
///
/// The button follows [SubscriptionPackage.action]: select a free plan,
/// pay online, request from admin, or nothing.
class PlanBottomBar extends StatelessWidget {
  const PlanBottomBar({
    super.key,
    required this.package,
    required this.isCurrent,
    required this.onPressed,
    this.isDowngradeBlocked = false,
    this.busy = false,
    this.lastRequest,
  });

  /// The user's newest request for this package, if any.
  final PackageRequest? lastRequest;

  bool get _hasPendingRequest => lastRequest?.isPending ?? false;

  final SubscriptionPackage package;
  final bool isCurrent;
  final VoidCallback onPressed;

  /// The user is on a paid plan and this is a free one: switching is not
  /// allowed, so the button is disabled with a short explanation.
  final bool isDowngradeBlocked;

  /// A payment or request is running: the button shows a spinner.
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

  /// Nothing to press: current plan, blocked downgrade, or no action.
  bool get _isPassive =>
      isCurrent ||
      isDowngradeBlocked ||
      _hasPendingRequest ||
      package.action == PlanAction.requestPending ||
      package.action == PlanAction.unavailable;

  String? get _note {
    if (isCurrent) return null;
    if (isDowngradeBlocked) {
      return 'You already enjoy everything in $_name. '
          'You can switch once your paid plan ends.';
    }
    final contact = package.contactAvailable
        ? ' Contact support if you need help.'
        : '';
    final request = lastRequest;
    if (request != null && request.isPending) {
      final sent = request.createdAt;
      final on = sent == null ? '' : ' on ${PackageFormat.date(sent)}';
      return 'You requested $_name$on. Our team is reviewing it.';
    }
    if (request != null &&
        request.isRejected &&
        package.action == PlanAction.request) {
      final reason = request.reviewReason;
      return 'Your last request was declined'
          '${reason == null ? '' : ': $reason'}. You can request again.';
    }
    return switch (package.action) {
      PlanAction.select => null,
      PlanAction.buy =>
        'Renews every ${PackageFormat.duration(package.billingDurationDays)}'
            ' · Cancel anytime',
      PlanAction.request =>
        "Online payment isn't available for $_name. "
            'Send a request and our team will get back to you.',
      PlanAction.requestPending =>
        'Your request for $_name is being reviewed.$contact',
      PlanAction.unavailable => "$_name isn't available right now.$contact",
    };
  }

  String get _passiveLabel {
    if (isCurrent) return "You're on $_name";
    if (isDowngradeBlocked) return 'Your paid plan is active';
    if (_hasPendingRequest || package.action == PlanAction.requestPending) {
      return 'Request pending';
    }
    return 'Not available';
  }

  String get _label => switch (package.action) {
    PlanAction.request when lastRequest?.isRejected ?? false =>
      'Request $_name again',
    PlanAction.request => 'Request $_name',
    _ => 'Continue with $_name',
  };

  Widget _buildButton(ColorScheme colors) {
    if (_isPassive) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          disabledForegroundColor: colors.onSurfaceVariant,
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Text(_passiveLabel),
      );
    }

    return FilledButton(
      onPressed: busy ? null : onPressed,
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
          : Text(_label),
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
