import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
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

bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

Color packageAccent(BuildContext c) =>
    _dark(c) ? AppColors.primaryDark : AppColors.primary;

/// Hero header: icon, headline and two highlight chips.
class PackagesHeader extends StatelessWidget {
  const PackagesHeader({super.key, required this.highlights});

  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    final accent = packageAccent(context);
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      color: accent.withValues(alpha: _dark(context) ? 0.22 : 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Get hired faster',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Apply to more jobs and stand out to recruiters with a verified profile.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in highlights)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 14, color: accent),
                        const SizedBox(width: 4),
                        Text(
                          h,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Selectable plan row: radio, name, key limits, price.
class PackageOptionCard extends StatelessWidget {
  const PackageOptionCard({
    super.key,
    required this.package,
    required this.selected,
    required this.recommended,
    required this.onTap,
  });

  final SubscriptionPackage package;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = packageAccent(context);
    final p = package;
    final limits = [
      if (p.monthlyApplications != null)
        '${PackageFormat.count(p.monthlyApplications)} applications',
      if (p.maxResumes != null) '${PackageFormat.count(p.maxResumes)} resumes',
    ].join(' · ');

    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: _dark(context) ? 0.18 : 0.06)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _Radio(selected: selected, color: accent),
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
                            p.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (recommended)
                            _Pill(
                              label: 'Most popular',
                              background: accent,
                              foreground: Colors.white,
                            ),
                        ],
                      ),
                      if (limits.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          limits,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      PackageFormat.duration(p.durationDays),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : Colors.transparent,
        border: Border.all(
          color: selected ? color : Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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

/// Feature-by-feature comparison of every plan.
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
    final accent = packageAccent(context);
    final border = theme.colorScheme.outlineVariant;

    Widget cell(Widget child, {bool highlight = false}) => Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 11),
        color: highlight ? accent.withValues(alpha: 0.06) : null,
        child: child,
      ),
    );

    Widget row(
      String label,
      IconData icon,
      List<Widget> values, {
      bool header = false,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: header ? theme.colorScheme.surfaceContainerHighest : null,
          border: header ? null : Border(top: BorderSide(color: border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    if (!header) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: header
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < packages.length; i++)
              cell(values[i], highlight: packages[i].id == selectedId),
          ],
        ),
      );
    }

    Widget value(String text, {bool bold = false}) => Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      ),
    );

    Widget tick(bool on) => Icon(
      on ? Icons.check_circle_rounded : Icons.remove_rounded,
      size: 18,
      color: on ? AppColors.success : theme.colorScheme.outline,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          row('Feature', Icons.circle, [
            for (final p in packages)
              Text(
                p.name
                    .replaceAll(RegExp(r'\s*(Candidate|Plan)\s*'), ' ')
                    .trim(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: p.id == selectedId ? accent : null,
                ),
              ),
          ], header: true),
          row('Applications / mo', Icons.send_outlined, [
            for (final p in packages)
              value(
                PackageFormat.count(p.monthlyApplications),
                bold: !p.isFree,
              ),
          ]),
          row('Resumes', Icons.description_outlined, [
            for (final p in packages)
              value(PackageFormat.count(p.maxResumes), bold: !p.isFree),
          ]),
          for (final f in PackageFeature.displayed.entries)
            row(f.value, _featureIcon(f.key), [
              for (final p in packages) tick(p.has(f.key)),
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
  const VerificationNote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This plan needs a quick profile verification before your '
              'verified badge appears.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
