import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../subscription_packages/domain/entities/subscription_package.dart';
import '../../../subscription_packages/presentation/widgets/package_widgets.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/plan_history_entry.dart';

/// Date and time formatting for the billing screens (device local time).
abstract final class BillingFormat {
  /// "18 Nov, 5:03 PM"
  static String dayTime(DateTime d) {
    final l = d.toLocal();
    return '${l.day} ${DateTimeUtils.months[l.month - 1]}, ${time(l)}';
  }

  /// "18 Nov 2026, 5:03 PM"
  static String fullDayTime(DateTime d) {
    final l = d.toLocal();
    return '${DateTimeUtils.day(l)}, ${time(l)}';
  }

  static String time(DateTime d) {
    final l = d.toLocal();
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    final m = l.minute.toString().padLeft(2, '0');
    return '$h:$m ${l.hour < 12 ? 'AM' : 'PM'}';
  }

  /// "28 Oct – 4 Nov 2026", or one date when both fall on the same day.
  static String range(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    if (start == null) return 'Until ${DateTimeUtils.day(end!.toLocal())}';
    final s = start.toLocal();
    if (end == null) return 'From ${DateTimeUtils.day(s)}';
    final e = end.toLocal();
    if (DateTimeUtils.isSameDay(s, e)) return DateTimeUtils.day(s);
    final left = s.year == e.year
        ? '${s.day} ${DateTimeUtils.months[s.month - 1]}'
        : DateTimeUtils.day(s);
    return '$left – ${DateTimeUtils.day(e)}';
  }

  static String monthTitle(DateTime d) {
    final l = d.toLocal();
    return '${DateTimeUtils.fullMonths[l.month - 1]} ${l.year}';
  }
}

/// Payment row: plan icon, name, time and duration, amount and status.
class PaymentRow extends StatelessWidget {
  const PaymentRow({
    super.key,
    required this.payment,
    required this.onTap,
    this.showDivider = true,
  });

  final PaymentRecord payment;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    final p = payment;
    final ok = p.isSuccess;
    final failed = p.status == PaymentStatus.failed;
    final danger = theme.colorScheme.error;

    final (statusText, statusColor) = switch (p.status) {
      PaymentStatus.success => ('Paid', c.success),
      PaymentStatus.failed => ('Failed', danger),
      PaymentStatus.pending => ('Pending', AppColors.warning),
      PaymentStatus.unknown => ('Unknown', c.muted),
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: showDivider ? Border(top: BorderSide(color: c.border)) : null,
        ),
        child: Row(
          children: [
            _IconTile(
              icon: failed
                  ? Icons.error_outline_rounded
                  : Icons.workspace_premium_outlined,
              color: failed ? danger : c.accentText,
              background: failed
                  ? danger.withValues(alpha: 0.12)
                  : c.accentSoft,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PackageFormat.shortName(p.packageName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: c.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${BillingFormat.dayTime(p.date)} · '
                    '${PackageFormat.duration(p.durationDays)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  PackageFormat.price(p.amountMinor, currency: p.currency),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ok ? c.text : c.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                _StatusDot(label: statusText, color: statusColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Past plan row: icon, name, dates and source, status.
class PlanHistoryRow extends StatelessWidget {
  const PlanHistoryRow({
    super.key,
    required this.entry,
    this.showDivider = true,
  });

  final PlanHistoryEntry entry;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    final e = entry;
    final isFree = e.packageCode.toUpperCase().contains('FREE');
    final meta = [
      BillingFormat.range(e.startsAt, e.endedAt),
      if (e.source.label.isNotEmpty) e.source.label,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showDivider ? Border(top: BorderSide(color: c.border)) : null,
      ),
      child: Row(
        children: [
          _IconTile(
            icon: isFree
                ? Icons.person_outline_rounded
                : Icons.workspace_premium_outlined,
            color: c.muted,
            background: c.panel,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PackageFormat.shortName(e.packageName),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            e.status.label,
            style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

/// The active plan: name, Active tag, source, progress to the end date and
/// a few feature chips.
class CurrentPlanHistoryCard extends StatelessWidget {
  const CurrentPlanHistoryCard({super.key, required this.entry});

  final PlanHistoryEntry entry;

  static const _featureLabels = {
    PackageFeature.jobAlerts: 'Job alerts',
    PackageFeature.verifiedBadge: 'Verified badge',
    PackageFeature.resumeCreation: 'Resume builder',
    'resumeBuilder': 'Resume builder',
    'resumeVisibility': 'Resume visibility',
    'profileVisibility': 'Profile visibility',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    final e = entry;
    final start = e.startsAt?.toLocal();
    final end = e.endedAt?.toLocal();
    final now = DateTime.now();

    double progress = 0;
    int? daysLeft;
    if (start != null && end != null && end.isAfter(start)) {
      final total = end.difference(start).inMinutes;
      final used = now.difference(start).inMinutes.clamp(0, total);
      progress = used / total;
      daysLeft = end.difference(now).inDays.clamp(0, 100000);
    }

    final chips = <String>[
      if (e.monthlyApplications != null)
        '${PackageFormat.count(e.monthlyApplications)} applications/mo',
      if (e.maxResumes != null) '${PackageFormat.count(e.maxResumes)} CVs',
      ...{
        for (final f in e.enabledFeatures)
          if (_featureLabels[f] != null) _featureLabels[f]!,
      },
    ];
    const maxChips = 4;
    final shown = chips.take(maxChips).toList();
    final extra = chips.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _IconTile(
              icon: Icons.workspace_premium_rounded,
              color: AppColors.white,
              background: c.accentFill,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        PackageFormat.shortName(e.packageName),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: c.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      PlanTag(
                        label: 'Active',
                        background: c.successSoft,
                        foreground: c.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (e.source.label.isNotEmpty) e.source.label,
                      PackageFormat.duration(e.durationDays),
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (start != null && end != null) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: c.panel,
              color: c.accentFill,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${start.day} ${DateTimeUtils.months[start.month - 1]}',
                style: theme.textTheme.labelSmall?.copyWith(color: c.muted),
              ),
              const Spacer(),
              if (daysLeft != null)
                Text(
                  daysLeft == 1 ? '1 day left' : '$daysLeft days left',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              Text(
                '${end.day} ${DateTimeUtils.months[end.month - 1]}',
                style: theme.textTheme.labelSmall?.copyWith(color: c.muted),
              ),
            ],
          ),
        ],
        if (shown.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final label in shown) _Chip(label: label),
              if (extra > 0) _Chip(label: '+$extra'),
            ],
          ),
        ],
      ],
    );
  }
}

/// Bottom sheet with a payment's details.
Future<void> showPaymentReceipt(BuildContext context, PaymentRecord payment) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => _ReceiptSheet(payment: payment),
  );
}

class _ReceiptSheet extends StatelessWidget {
  const _ReceiptSheet({required this.payment});

  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    final p = payment;
    final ok = p.isSuccess;
    final danger = theme.colorScheme.error;
    final accent = ok ? c.success : danger;
    final id = p.providerPaymentId;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? c.successSoft : danger.withValues(alpha: 0.12),
            ),
            child: Icon(
              ok ? Icons.check_rounded : Icons.close_rounded,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            PackageFormat.price(p.amountMinor, currency: p.currency),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: ok ? c.text : c.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ok
                ? 'Paid · ${BillingFormat.fullDayTime(p.date)}'
                : 'Payment failed · ${BillingFormat.fullDayTime(p.date)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ok ? c.muted : danger,
            ),
          ),
          const SizedBox(height: 18),
          PlanSection(
            title: 'Details',
            child: Column(
              children: [
                _DetailRow(
                  label: 'Plan',
                  value: PackageFormat.shortName(p.packageName),
                  first: true,
                ),
                _DetailRow(
                  label: 'Duration',
                  value: PackageFormat.duration(p.durationDays),
                ),
                _DetailRow(
                  label: ok ? 'Paid on' : 'Attempted on',
                  value: BillingFormat.fullDayTime(p.date),
                ),
                if (id != null)
                  _DetailRow(
                    label: 'Payment ID',
                    value: id,
                    mono: true,
                    onCopy: () => _copy(context, id),
                  ),
              ],
            ),
          ),
          if (id != null)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.band, width: 8)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: OutlinedButton.icon(
                  onPressed: () => _copy(context, id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    foregroundColor: c.text,
                    side: BorderSide(color: c.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy payment ID'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> _copy(BuildContext context, String id) async {
    await Clipboard.setData(ClipboardData(text: id));
    AppSnackbar.success(title: 'Payment ID copied');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.first = false,
    this.mono = false,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool first;
  final bool mono;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: c.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.text,
                fontFamily: mono ? 'monospace' : null,
                fontSize: mono ? 13 : null,
              ),
            ),
          ),
          if (onCopy != null) ...[
            const SizedBox(width: 4),
            InkResponse(
              onTap: onCopy,
              radius: 18,
              child: Icon(Icons.copy_rounded, size: 16, color: c.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = PlanColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.panel,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.muted),
      ),
    );
  }
}
