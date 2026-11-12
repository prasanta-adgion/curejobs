import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../core/widgets/app_error_view.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../../../shared/widgets/entry_more_menu.dart';
import '../../domain/entities/experience.dart';
import '../bloc/experience_bloc.dart';
import '../pages/edit_experience_form_page.dart';
import 'delete_experience_sheet.dart';

/// Work history as a vertical timeline. Owns its [ExperienceBloc].
///
/// Add, edit and delete are handled here with the built-in form.
class ExperienceTab extends StatelessWidget {
  const ExperienceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExperienceBloc>()..add(const ExperienceRequested()),
      child: BlocConsumer<ExperienceBloc, ExperienceState>(
        listenWhen: (prev, curr) =>
            curr.deleteFailure != null &&
            prev.deleteFailure != curr.deleteFailure,
        listener: (context, state) => AppSnackbar.error(
          title: "Couldn't delete this position",
          message: state.deleteFailure?.message ?? 'Try again in a moment.',
        ),
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ExperienceStatus.failure && state.items.isEmpty) {
            return AppErrorView(
              failure: state.failure!,
              onRetry: () => context.read<ExperienceBloc>().add(
                const ExperienceRequested(),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<ExperienceBloc>()
                ..add(const ExperienceRequested());
              await bloc.stream.firstWhere((s) => !s.isLoading);
            },
            child: _ExperienceList(
              items: state.items,
              onAdd: () => _openForm(context),
              onEdit: (item) => _openForm(context, item),
              onDelete: (item) => _confirmDelete(context, item),
            ),
          );
        },
      ),
    );
  }

  /// Opens the add / edit form and reloads the list if it saved.
  static Future<void> _openForm(
    BuildContext context, [
    Experience? experience,
  ]) async {
    final bloc = context.read<ExperienceBloc>();
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ExperienceFormPage(experience: experience),
      ),
    );
    if (changed ?? false) bloc.add(const ExperienceRequested());
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    Experience experience,
  ) async {
    final bloc = context.read<ExperienceBloc>();
    final confirmed = await showDeleteExperienceSheet(context, experience);
    if (confirmed) bloc.add(ExperienceDeleted(experience.id));
  }
}

class _ExperienceList extends StatelessWidget {
  const _ExperienceList({
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Experience> items;
  final VoidCallback onAdd;
  final ValueChanged<Experience> onEdit;
  final ValueChanged<Experience> onDelete;

  String _title(DateTime now) {
    final count = items.length == 1
        ? '1 position'
        : '${items.length} positions';
    final total = Experience.formatMonths(
      items.fold(0, (sum, e) => sum + e.monthsAt(now)),
    );
    return total.isEmpty ? count : '$count · $total';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ProfileSection(
          title: _title(now),
          showDivider: false,
          action: SectionAction(
            label: 'Add',
            icon: Icons.add,
            onPressed: onAdd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _TimelineEntry(
                  key: ValueKey(items[i].id),
                  item: items[i],
                  duration: items[i].durationAt(now),
                  isLast: i == items.length - 1,
                  onEdit: () => onEdit(items[i]),
                  onDelete: () => onDelete(items[i]),
                ),
                if (i < items.length - 1)
                  _GapMarker(months: items[i].gapAfter(items[i + 1])),
              ],
              if (items.isNotEmpty) const SizedBox(height: 14),
              _AddPositionCard(isFirst: items.isEmpty, onTap: onAdd),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dashed card at the end of the timeline; doubles as the empty state.
class _AddPositionCard extends StatelessWidget {
  const _AddPositionCard({required this.isFirst, required this.onTap});

  final bool isFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(left: isFirst ? 0 : _tileSize + _railGap),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: scheme.primary.withValues(alpha: 0.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isFirst ? 24 : 14),
            child: Column(
              children: [
                if (isFirst) ...[
                  Icon(AppIcons.work, color: scheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first position',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Employers look here first.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ] else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Add another position',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
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

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

/// Width of the organization tile on the timeline, and the gap after it.
const double _tileSize = 40;
const double _railGap = 12;

/// One position: organization tile on the timeline and a card with the
/// role, key facts and responsibilities (collapsed to two lines).
class _TimelineEntry extends StatefulWidget {
  const _TimelineEntry({
    super.key,
    required this.item,
    required this.duration,
    required this.isLast,
    this.onEdit,
    this.onDelete,
  });

  final Experience item;
  final String duration;
  final bool isLast;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_TimelineEntry> createState() => _TimelineEntryState();
}

class _TimelineEntryState extends State<_TimelineEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;
    final isCurrent = item.currentlyWorking;
    final typeLabel = item.employmentTypeLabel;
    final location = item.location;
    final responsibilities = item.responsibilities?.trim() ?? '';
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    // A Stack instead of IntrinsicHeight: the rail stretches to the card's
    // height, and the card can use LayoutBuilder (Show more).
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _tileSize,
          child: Column(
            children: [
              _OrganizationTile(initials: item.initials, highlight: isCurrent),
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          isCurrent ? scheme.primary : scheme.outlineVariant,
                          scheme.outlineVariant,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: _tileSize + _railGap),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
            decoration: BoxDecoration(
              color: isCurrent
                  ? scheme.primaryContainer.withValues(alpha: 0.25)
                  : scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent
                    ? scheme.primary.withValues(alpha: 0.3)
                    : scheme.outlineVariant,
                width: isCurrent ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isCurrent) ...[
                            const _CurrentBadge(),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            item.jobTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.organizationName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: EntryMoreMenu(
                        title: item.jobTitle,
                        subtitle: item.organizationName,
                        editHint: 'Role, dates, responsibilities',
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                      ),
                    ),
                  ],
                ),
                if (widget.duration.isNotEmpty || typeLabel != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (widget.duration.isNotEmpty)
                        _FactChip(
                          icon: Icons.schedule_rounded,
                          label: widget.duration,
                          accent: isCurrent,
                        ),
                      if (typeLabel != null)
                        _FactChip(icon: AppIcons.work, label: typeLabel),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    if (item.period.isNotEmpty)
                      _IconText(
                        icon: AppIcons.calendar,
                        text: item.period,
                        style: muted,
                      ),
                    if (location != null && location.isNotEmpty)
                      _IconText(
                        icon: Icons.location_on_outlined,
                        text: location,
                        style: muted,
                      ),
                  ],
                ),
                if (responsibilities.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, right: 10),
                    child: CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: _DashedLinePainter(color: scheme.outlineVariant),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _Responsibilities(
                      text: responsibilities,
                      expanded: _expanded,
                      onToggle: () => setState(() => _expanded = !_expanded),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Rounded square with the organization's initials.
class _OrganizationTile extends StatelessWidget {
  const _OrganizationTile({required this.initials, required this.highlight});

  final String initials;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: _tileSize,
      height: _tileSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlight ? scheme.primary : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        initials,
        style: theme.textTheme.labelLarge?.copyWith(
          color: highlight ? scheme.onPrimary : scheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Green dot with "Current role".
class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.successLight, width: 0),
            boxShadow: const [
              BoxShadow(color: AppColors.successLight, spreadRadius: 3),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Current role',
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Small tinted chip with an icon, e.g. duration or employment type.
class _FactChip extends StatelessWidget {
  const _FactChip({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = accent ? scheme.primary : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent
            ? scheme.primaryContainer.withValues(alpha: 0.6)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: fg)),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text, this.style});

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: style?.color),
        const SizedBox(width: 4),
        Text(text, style: style),
      ],
    );
  }
}

/// Responsibilities clamped to two lines, with Show more / Show less when
/// the text doesn't fit.
class _Responsibilities extends StatelessWidget {
  const _Responsibilities({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  static const _collapsedLines = 2;

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = theme.textTheme.bodyMedium?.copyWith(height: 1.5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: _collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                text,
                style: style,
                maxLines: expanded ? null : _collapsedLines,
                overflow: expanded ? null : TextOverflow.ellipsis,
              ),
            ),
            if (overflows || expanded)
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        expanded ? 'Show less' : 'Show more',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Dotted rail and a "N months gap" chip between two positions.
/// Draws a plain spacer when there's no gap.
class _GapMarker extends StatelessWidget {
  const _GapMarker({required this.months});

  final int months;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (months <= 0) {
      return Row(
        children: [
          SizedBox(
            width: _tileSize,
            height: 12,
            child: Center(
              child: Container(width: 2, color: scheme.outlineVariant),
            ),
          ),
        ],
      );
    }

    final label = months == 1
        ? '1 month gap'
        : months < 12
        ? '$months months gap'
        : '${Experience.formatMonths(months)} gap';

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          SizedBox(
            width: _tileSize,
            child: Center(
              child: CustomPaint(
                size: const Size(2, 36),
                painter: _DottedRailPainter(color: scheme.outlineVariant),
              ),
            ),
          ),
          const SizedBox(width: _railGap),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedRailPainter extends CustomPainter {
  const _DottedRailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var y = 3.0; y < size.height; y += 6) {
      canvas.drawLine(Offset(1, y), Offset(1, y + 2), paint);
    }
  }

  @override
  bool shouldRepaint(_DottedRailPainter old) => old.color != color;
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
