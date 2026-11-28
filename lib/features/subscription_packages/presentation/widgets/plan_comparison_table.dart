import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import '../../domain/entities/subscription_package.dart';
import 'plan_format.dart';

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
    final colors = context.colors;

    Widget cell(SubscriptionPackage p, Widget child) {
      final on = p.id == selectedId;
      return Expanded(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          color: on ? colors.primaryContainer : null,
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
            Icon(icon, size: 16, color: colors.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Widget row(Widget first, List<Widget> cells, {bool header = false}) =>
        Container(
          decoration: BoxDecoration(
            color: header ? colors.surfaceContainerHighest : null,
            border: header
                ? null
                : Border(top: BorderSide(color: colors.outlineVariant)),
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
          color: on ? colors.onSurface : colors.onSurfaceVariant,
          fontWeight: on ? FontWeight.w700 : FontWeight.w400,
        ),
      );
    }

    Widget tick(bool included) => Icon(
      included ? Icons.check_circle_rounded : Icons.remove_rounded,
      size: 18,
      color: included ? context.successColor : colors.outline,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
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
                    color: colors.onSurfaceVariant,
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
                          color: colors.primary,
                        ),
                      Text(
                        PackageFormat.shortName(p.name),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.id == selectedId
                              ? colors.primary
                              : colors.onSurfaceVariant,
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
