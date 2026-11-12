import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/entry_more_menu.dart';
import '../../domain/entities/education.dart';

/// One education card on the timeline. Tap to edit; ⋮ for Edit and Delete.
///
/// [highlighted] marks the latest entry with a solid tile and tinted card.
/// [showLine] draws the timeline line down to the next card.
class EducationTile extends StatefulWidget {
  const EducationTile({
    super.key,
    required this.item,
    required this.highlighted,
    required this.showLine,
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
  });

  final Education item;
  final bool highlighted;
  final bool showLine;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<EducationTile> createState() => _EducationTileState();
}

class _EducationTileState extends State<EducationTile> {
  final _expanded = ValueNotifier(false);

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  /// "4 yrs", "1 yr", or null when the years aren't known.
  String? get _duration {
    final item = widget.item;
    final start = item.startYear;
    final end = item.currentlyStudying
        ? DateTime.now().year
        : item.completionYear;
    if (start == null || end == null) return null;
    final years = end - start;
    if (years <= 0) return null;
    return years == 1 ? '1 yr' : '$years yrs';
  }

  IconData get _icon {
    final degree = widget.item.degree.toLowerCase();
    if (degree.contains('secondary') || degree.contains('school')) {
      return Icons.menu_book_outlined;
    }
    if (degree.contains('diploma') || degree.contains('certificate')) {
      return Icons.workspace_premium_outlined;
    }
    return Icons.school_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;
    final highlighted = widget.highlighted;
    final enabled = !widget.deleting;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.deleting ? 0.5 : 1,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: highlighted
                          ? scheme.primary
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _icon,
                      size: 20,
                      color: highlighted
                          ? scheme.onPrimary
                          : scheme.onPrimaryContainer,
                    ),
                  ),
                  if (widget.showLine)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: scheme.primaryContainer,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: widget.showLine ? 12 : 0),
                child: Material(
                  color: highlighted
                      ? scheme.primaryContainer.withValues(alpha: 0.25)
                      : scheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: highlighted
                          ? scheme.primary.withValues(alpha: 0.45)
                          : scheme.outlineVariant,
                      width: highlighted ? 1.5 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: enabled ? widget.onEdit : null,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
                      child: _content(theme, scheme, item, enabled),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(
    ThemeData theme,
    ColorScheme scheme,
    Education item,
    bool enabled,
  ) {
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final field = item.fieldOfStudy;
    final description = item.description;
    final duration = _duration;
    final period = [
      if (item.period.isNotEmpty) item.period,
      ?duration,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  item.degree,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _StatusBadge(ongoing: item.currentlyStudying),
            ),
            SizedBox.square(
              dimension: 32,
              child: widget.deleting
                  ? Center(
                      child: SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      ),
                    )
                  : EntryMoreMenu(
                      title: item.degree,
                      subtitle: item.institution,
                      editHint: 'Degree, years, description',
                      onEdit: widget.onEdit,
                      onDelete: widget.onDelete,
                    ),
            ),
          ],
        ),
        if (field != null && field.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              field,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 6),
        _InfoLine(icon: Icons.apartment_rounded, text: item.institution),
        if (period.isNotEmpty) ...[
          const SizedBox(height: 2),
          _InfoLine(icon: AppIcons.calendar, text: period),
        ],
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ValueListenableBuilder<bool>(
              valueListenable: _expanded,
              builder: (context, expanded, _) => GestureDetector(
                onTap: () => _expanded.value = !expanded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      maxLines: expanded ? null : 2,
                      overflow: expanded ? null : TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                    if (description.length > 90)
                      Text(
                        expanded ? 'Show less' : 'More',
                        style: muted?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.ongoing});

  final bool ongoing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final green = isDark ? const Color(0xFF97C459) : const Color(0xFF27500A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ongoing
            ? green.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ongoing) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: green, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            ongoing ? 'Ongoing' : 'Completed',
            style: theme.textTheme.labelSmall?.copyWith(
              color: ongoing ? green : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
