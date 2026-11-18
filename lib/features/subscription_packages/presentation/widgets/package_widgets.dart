import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../subscription_plan_buy_history/presentation/pages/billing_history_page.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/entities/subscription_package.dart';

/// Formatting helpers for plan prices and durations.
abstract final class PackageFormat {
  static String price(int amountMinor, {String currency = 'INR'}) {
    final symbol = currency == 'INR' ? '₹' : '$currency ';
    final value = amountMinor / 100;
    final whole = value == value.roundToDouble();
    return '$symbol${_group(whole ? value.round().toString() : value.toStringAsFixed(2))}';
  }

  static String duration(int days) {
    if (days <= 0) return '';
    if (days % 365 == 0) return days == 365 ? '1 year' : '${days ~/ 365} years';
    if (days % 30 == 0) return days == 30 ? '1 month' : '${days ~/ 30} months';
    if (days % 7 == 0) return days == 7 ? '1 week' : '${days ~/ 7} weeks';
    return days == 1 ? '1 day' : '$days days';
  }

  static String count(int? n) => n == null ? '—' : _group(n.toString());

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String date(DateTime d) {
    final l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }

  /// "Free Candidate Plan" → "Free", "Candidate Starter Plan" → "Starter".
  static String shortName(String name) {
    final s = name.replaceAll(RegExp(r'\b(Candidate|Plan)\b'), '').trim();
    return s.replaceAll(RegExp(r'\s+'), ' ').isEmpty ? name : s;
  }

  /// Indian digit grouping: 100000 → 1,00,000.
  static String _group(String s) {
    final parts = s.split('.');
    final digits = parts.first;
    if (digits.length <= 3) return s;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    final grouped = '${groups.join(',')},$last3';
    return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
  }
}

/// Plan-screen colours that stay readable in both themes.
///
/// Purple *text* uses the light purple in dark mode; solid purple *fills*
/// keep the brand purple with white text on top.
class PlanColors {
  PlanColors.of(BuildContext context)
    : _dark = Theme.of(context).brightness == Brightness.dark,
      _scheme = Theme.of(context).colorScheme;

  final bool _dark;
  final ColorScheme _scheme;

  /// Purple for text, icons and the selected border.
  Color get accentText => _dark ? AppColors.darkPrimary : AppColors.primary;

  /// Solid purple behind white text (main button, "Most popular").
  Color get accentFill => AppColors.primary;

  /// Soft purple behind content (selected card, highlighted column).
  Color get accentSoft => _dark
      ? AppColors.darkPrimaryContainer
      : AppColors.primary.withValues(alpha: 0.07);

  Color get text => _scheme.onSurface;
  Color get muted => _scheme.onSurfaceVariant;

  /// For "not included" marks; dimmer than [muted].
  Color get dim => _scheme.outline;
  Color get border => _scheme.outlineVariant;
  Color get surface => _scheme.surface;

  /// Thick band between sections, like the Profile tabs.
  Color get band => _scheme.surfaceContainerHighest;

  /// Grey panel for notes and the table header.
  Color get panel => _scheme.surfaceContainerHighest;

  Color get success => _dark ? AppColors.successDark : AppColors.success;
  Color get successSoft => _dark
      ? AppColors.successDark.withValues(alpha: 0.16)
      : AppColors.successLight;
}

/// A titled block separated by a thick band, matching `ProfileSection`.
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
  final Widget? trailing;
  final bool showBand;

  @override
  Widget build(BuildContext context) {
    final c = PlanColors.of(context);
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: showBand
            ? Border(top: BorderSide(color: c.band, width: 8))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 28,
              child: Row(
                children: [
                  Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: c.muted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
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

/// Navy hero with back button, headline and highlight chips. Navy in both
/// themes, so its colours are fixed.
class PackagesHeader extends StatelessWidget {
  const PackagesHeader({super.key, required this.highlights});

  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: AppColors.logoNavy,
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 22),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BackButton(color: AppColors.white),
                Text(
                  'Plans',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).push(BillingHistoryPage.route()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppColors.darkInputBorder),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: Text(
                    'Billing history',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get hired faster',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'More applications, job alerts and a verified '
                              'profile.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.darkTextSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (highlights.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final h in highlights) _HeaderChip(label: h),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkPrimaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            size: 14,
            color: AppColors.darkPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.darkPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "Your current plan": name, Active tag, end date and the two limits.
class CurrentPlanSummary extends StatelessWidget {
  const CurrentPlanSummary({super.key, required this.subscription});

  final CurrentSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    final s = subscription;
    final ending = s.isEndingSoon;
    final end = s.expiresAt;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: s.isFree ? c.accentSoft : c.accentFill,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                s.isFree
                    ? Icons.person_outline_rounded
                    : Icons.workspace_premium_rounded,
                size: 22,
                color: s.isFree ? c.accentText : AppColors.white,
              ),
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
                        PackageFormat.shortName(s.package.name),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: c.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (s.isActive)
                        PlanTag(
                          label: 'Active',
                          background: c.successSoft,
                          foreground: c.success,
                        ),
                    ],
                  ),
                  if (end != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      ending
                          ? 'Ends in ${s.daysLeft()} days · ${PackageFormat.date(end)}'
                          : 'Valid till ${PackageFormat.date(end)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ending ? AppColors.warning : c.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(height: 1, color: c.border),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _Limit(
                  icon: Icons.send_outlined,
                  value: PackageFormat.count(s.monthlyApplications),
                  suffix: ' / month',
                  label: 'Applications',
                ),
              ),
              VerticalDivider(width: 1, color: c.border),
              const SizedBox(width: 14),
              Expanded(
                child: _Limit(
                  icon: Icons.upload_file_outlined,
                  value: PackageFormat.count(s.maxResumes),
                  suffix: ' max',
                  label: 'CV uploads',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Limit extends StatelessWidget {
  const _Limit({
    required this.icon,
    required this.value,
    required this.suffix,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String suffix;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    return Row(
      children: [
        Icon(icon, size: 19, color: c.muted),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: c.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: suffix,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Selectable plan row: radio, name + tags, key limits, price.
class PackageOptionCard extends StatelessWidget {
  const PackageOptionCard({
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    final p = package;
    final limits = [
      if (p.monthlyApplications != null)
        '${PackageFormat.count(p.monthlyApplications)} applications',
      if (p.maxResumes != null) '${PackageFormat.count(p.maxResumes)} CVs',
    ].join(' · ');

    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selected ? c.accentSoft : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? c.accentText : c.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _Radio(selected: selected),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              PackageFormat.shortName(p.name),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: c.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isCurrent)
                              PlanTag(
                                label: 'Current',
                                background: c.successSoft,
                                foreground: c.success,
                              )
                            else if (recommended)
                              PlanTag(
                                label: 'Most popular',
                                background: c.accentFill,
                                foreground: AppColors.white,
                              ),
                          ],
                        ),
                        if (limits.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            limits,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: c.muted,
                            ),
                          ),
                        ],
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
                                p.priceMinor,
                                currency: p.currency,
                              ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: c.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        PackageFormat.duration(p.durationDays),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = PlanColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? c.accentText : Colors.transparent,
        border: Border.all(color: selected ? c.accentText : c.dim, width: 1.5),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 15, color: c.surface)
          : null,
    );
  }
}

/// "Showing details for Starter · ₹499 · 1 week" strip above the table.
class SelectedPlanBanner extends StatelessWidget {
  const SelectedPlanBanner({
    super.key,
    required this.package,
    required this.isCurrent,
  });

  final SubscriptionPackage package;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    final p = package;
    final meta = isCurrent
        ? 'Your current plan'
        : p.isFree
        ? PackageFormat.duration(p.durationDays)
        : '${PackageFormat.price(p.priceMinor, currency: p.currency)} · '
              '${PackageFormat.duration(p.durationDays)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: c.accentText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(color: c.text),
                children: [
                  const TextSpan(text: 'Showing details for '),
                  TextSpan(
                    text: PackageFormat.shortName(p.name),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            meta,
            style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

/// Feature-by-feature comparison; the selected plan's column is tinted,
/// ticked in the header and shown in bold.
class PackageComparisonTable extends StatelessWidget {
  const PackageComparisonTable({
    super.key,
    required this.packages,
    required this.selectedId,
  });

  final List<SubscriptionPackage> packages;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);

    Widget cell(SubscriptionPackage p, Widget child) {
      final on = p.id == selectedId;
      return Expanded(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          color: on ? c.accentSoft : null,
          child: child,
        ),
      );
    }

    Widget label(String text, IconData icon) => Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 16, color: c.muted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(color: c.text),
              ),
            ),
          ],
        ),
      ),
    );

    Widget row(Widget first, List<Widget> cells, {bool header = false}) =>
        Container(
          decoration: BoxDecoration(
            color: header ? c.panel : null,
            border: header ? null : Border(top: BorderSide(color: c.border)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [first, ...cells],
            ),
          ),
        );

    Widget value(SubscriptionPackage p, String text) {
      final on = p.id == selectedId;
      return Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: on ? c.text : c.muted,
          fontWeight: on ? FontWeight.w700 : FontWeight.w400,
        ),
      );
    }

    Widget tick(bool included) => Icon(
      included ? Icons.check_circle_rounded : Icons.remove_rounded,
      size: 18,
      color: included ? c.success : c.dim,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          row(
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Text(
                  'Feature',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: c.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            [
              for (final p in packages)
                cell(
                  p,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (p.id == selectedId)
                        Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: c.accentText,
                        ),
                      Text(
                        PackageFormat.shortName(p.name),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.id == selectedId ? c.accentText : c.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            header: true,
          ),
          row(label('Applications / mo', Icons.send_outlined), [
            for (final p in packages)
              cell(p, value(p, PackageFormat.count(p.monthlyApplications))),
          ]),
          row(label('CVs', Icons.description_outlined), [
            for (final p in packages)
              cell(p, value(p, PackageFormat.count(p.maxResumes))),
          ]),
          for (final f in PackageFeature.displayed.entries)
            row(label(f.value, _featureIcon(f.key)), [
              for (final p in packages) cell(p, tick(p.has(f.key))),
            ]),
        ],
      ),
    );
  }

  static IconData _featureIcon(String key) => switch (key) {
    PackageFeature.resumeCreation => Icons.edit_note_rounded,
    PackageFeature.jobApplications => Icons.work_outline_rounded,
    PackageFeature.jobAlerts => Icons.notifications_none_rounded,
    PackageFeature.verifiedBadge => Icons.verified_outlined,
    _ => Icons.check_rounded,
  };
}

/// Calm note shown when the selected plan needs a profile check.
class VerificationNote extends StatelessWidget {
  const VerificationNote({super.key, required this.planName});

  final String planName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = PlanColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: c.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$planName needs a quick profile check before your verified '
              'badge appears.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: c.muted,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
