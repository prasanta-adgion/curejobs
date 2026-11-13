import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../models/application_ui_model.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatShortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// One application as a white bordered card, matching the dashboard job
/// card: title and status, location, highlights, then a footer with the
/// progress and the next action. Withdrawn cards are muted.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.item,
    this.onTap,
    this.onWithdraw,
    this.onReapply,
    this.isWithdrawing = false,
  });

  final JobApplication item;

  /// Shows a spinner in place of the Withdraw button.
  final bool isWithdrawing;
  final VoidCallback? onTap;
  final VoidCallback? onWithdraw;
  final VoidCallback? onReapply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final status = item.status;
    final colors = status.colors(context);
    final isWithdrawn = status == ApplicationStatus.withdrawn;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = dark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    final locationLine = [
      if (item.location.isNotEmpty) item.location,
      if (isWithdrawn && item.withdrawnAt != null)
        'Withdrawn ${formatShortDate(item.withdrawnAt!)}',
    ].join(' · ');

    final footer = _footer(context, colors, border);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: isWithdrawn
            ? Color.alphaBlend(
                scheme.onSurface.withValues(alpha: 0.02),
                scheme.surface,
              )
            : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.jobTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isWithdrawn
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Badge(label: status.label, colors: colors),
                  ],
                ),
                if (locationLine.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: scheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isWithdrawn
                                ? muted
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (!isWithdrawn) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Highlight(
                        icon: Icons.calendar_today_outlined,
                        label: 'Applied ${formatShortDate(item.appliedAt)}',
                      ),
                      if (!item.isJobOpen)
                        _Highlight(
                          icon: Icons.timer_off_outlined,
                          label: 'Job expired',
                          colors: ApplicationStatus.rejected.colors(context),
                        ),
                    ],
                  ),
                ],
                if (footer != null) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, thickness: 1, color: border),
                  const SizedBox(height: 10),
                  footer,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _footer(BuildContext context, StatusColors colors, Color border) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = item.status;

    switch (status) {
      case ApplicationStatus.withdrawn:
        if (!item.isJobOpen) return null;
        return Row(
          children: [
            _Highlight(
              icon: Icons.check_circle_outline_rounded,
              label: 'Still hiring',
              colors: ApplicationStatus.selected.colors(context),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: onReapply,
              style: _buttonStyle(context, scheme.primary, scheme.primary),
              child: const Text('Reapply'),
            ),
          ],
        );

      case ApplicationStatus.selected:
        return Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 16, color: colors.fg),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "You've been selected. The hospital will contact you.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.fg,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );

      case ApplicationStatus.rejected:
        return null;

      case ApplicationStatus.applied ||
          ApplicationStatus.underReview ||
          ApplicationStatus.shortlisted:
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: _Progress(step: status.progressStep, color: colors.fg),
                ),
                const SizedBox(height: 5),
                Text(
                  'Step ${status.progressStep} of 4 · ${status.label}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isWithdrawing)
              SizedBox.square(
                dimension: 32,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.error,
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: onWithdraw,
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: const Text('Withdraw'),
                style: _buttonStyle(
                  context,
                  scheme.error,
                  scheme.error.withValues(alpha: 0.35),
                ),
              ),
          ],
        );
    }
  }

  ButtonStyle _buttonStyle(BuildContext context, Color fg, Color side) {
    return OutlinedButton.styleFrom(
      foregroundColor: fg,
      side: BorderSide(color: side),
      minimumSize: const Size(0, 32),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: Theme.of(context).textTheme.labelMedium
          ?.copyWith(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    );
  }
}

/// Status badge, same shape as the dashboard "New" / "Sponsored" badge.
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.colors});

  final String label;
  final StatusColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Highlight tag with an icon, like the job card. Brand violet unless
/// [colors] is given.
class _Highlight extends StatelessWidget {
  const _Highlight({required this.icon, required this.label, this.colors});

  final IconData icon;
  final String label;
  final StatusColors? colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final brand = dark ? AppColors.darkPrimary : AppColors.primary;
    final fg = colors?.fg ?? brand;
    final bg =
        colors?.bg ??
        (dark ? brand.withValues(alpha: 0.16) : AppColors.primaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.small - 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 4 slim segments: Applied → Review → Shortlist → Result.
class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.color});

  final int step;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < step ? color : track,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
